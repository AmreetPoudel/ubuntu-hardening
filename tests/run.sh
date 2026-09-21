#!/usr/bin/env bash
# End-to-end test on a disposable Ubuntu 24.04 container (systemd + sshd), connected to exactly like a real host
# (SSH + password + sudo). Needs docker, sshpass and ansible on the machine running it.
#
# Checks: first apply succeeds -> second apply changes nothing -> --check changes nothing -> workload plays
# succeed -> the audit passes (container-only limits excepted) -> the account can still log in over SSH.
set -euo pipefail
cd "$(dirname "$0")/.."

IMAGE=hardening-test-ubuntu
NAME=hardening-test-node
PORT=${PORT:-2222}
MIN_SCORE=${MIN_SCORE:-95}
INVENTORY=inventory.test.ini            # git-ignored
export ANSIBLE_HOST_KEY_CHECKING=False

log() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
run() { ansible-playbook -i "$INVENTORY" "$@" -l t1 -e ssh_allow_port_change=true; }
recap() { grep -E '^t1 +:' | tail -1; }
field() { grep -oE "$1=[0-9]+" | tail -1 | cut -d= -f2; }

cleanup() { docker rm -f "$NAME" >/dev/null 2>&1 || true; rm -f "$INVENTORY"; }
trap cleanup EXIT

log "Building image and starting the target"
docker build -q -t "$IMAGE" tests >/dev/null
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d --name "$NAME" --privileged --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --tmpfs /run --tmpfs /run/lock --tmpfs /tmp -p "$PORT:22" "$IMAGE" >/dev/null

cat > "$INVENTORY" <<INV
[standalone]
t1 ansible_host=127.0.0.1 ansible_port=$PORT ansible_user=admin ansible_ssh_pass=Admin-pass-123 ansible_become_password=Admin-pass-123

[web_nodes]
t1

[db_nodes]
t1

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args=-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
INV

for _ in $(seq 1 30); do ansible -i "$INVENTORY" t1 -m ping >/dev/null 2>&1 && break; sleep 2; done
docker exec "$NAME" systemctl start postgresql nginx

log "1/6 Apply base OS hardening"
out=$(run playbooks/base_os.yml 2>&1) || { echo "$out" | tail -40; exit 1; }
echo "$out" | recap

log "2/6 Second apply must change nothing (idempotence)"
out=$(run playbooks/base_os.yml 2>&1) || { echo "$out" | tail -40; exit 1; }
echo "$out" | recap
[ "$(echo "$out" | field changed)" = 0 ] || { echo "$out" | grep -B2 '^changed:' ; echo "FAIL: not idempotent"; exit 1; }

log "3/6 --check must change nothing and not fail"
out=$(run playbooks/base_os.yml --check 2>&1) || { echo "$out" | tail -40; exit 1; }
echo "$out" | recap
[ "$(echo "$out" | field changed)" = 0 ] || { echo "FAIL: --check reports changes"; exit 1; }

log "4/6 Workload playbooks (nginx, postgresql), twice"
for _ in 1 2; do
  out=$(run playbooks/web_server.yml playbooks/database_server.yml 2>&1) || { echo "$out" | tail -40; exit 1; }
done
echo "$out" | recap
[ "$(echo "$out" | field changed)" = 0 ] || { echo "FAIL: workload plays not idempotent"; exit 1; }

log "5/6 Compliance audit (score >= $MIN_SCORE%; auditd/AppArmor cannot run in a container)"
out=$(run playbooks/audit_compliance.yml 2>&1) || { echo "$out" | tail -40; exit 1; }
score=$(echo "$out" | tr -s " \n" " " | sed -nE 's/.*t1: ([0-9.]+)%.*/\1/p')
echo "score: ${score}%"
awk -v s="$score" -v m="$MIN_SCORE" 'BEGIN { exit !(s >= m) }' || { echo "$out" | grep -E "FAIL \[" ; echo "FAIL: score below $MIN_SCORE%"; exit 1; }

log "6/6 The connection user can still log in over SSH with the hardened configuration"
sshpass -p Admin-pass-123 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR \
  -o PubkeyAuthentication=no -p "$PORT" admin@127.0.0.1 'sudo -n true 2>/dev/null || echo "(sudo needs a password, as expected)"; echo login ok'

log "All checks passed"
