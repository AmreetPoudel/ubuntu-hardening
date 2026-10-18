# Ubuntu 24.04 hardening (Ansible)

Idempotent, check-mode-safe hardening for Ubuntu 24.04 servers: base OS, Docker hosts, Kubernetes nodes,
PostgreSQL and Nginx, plus a read-only compliance audit. Hosts live in one Ansible-Vault-encrypted `inventory.ini`.

## Requirements

- Control node: `ansible-core` 2.16+, `sshpass` (password logins), `make deps` for the collections
- Targets: Ubuntu 24.04 LTS, a non-root sudo user (root is refused by design)

## First-time setup

```bash
cp inventory.example.ini inventory.ini     # your servers, users and passwords
ansible-vault encrypt inventory.ini        # edit it later with: ansible-vault edit inventory.ini
make deps                                  # ansible.posix, community.general
ansible -J all -m ping                     # every server must answer "pong"
```

Then open `group_vars/all.yml`, put **your own** public key in `ssh_authorized_keys` (it ships with the maintainer's
key), and check the settings listed under [Configuration](#configuration).

`-J` asks for the vault password. Every command in this README needs it, because the inventory is encrypted.

## 1. Put each server in a group

| Server | Inventory group | It gets |
|---|---|---|
| Plain server | `standalone` | base OS hardening |
| Docker host | `docker_nodes` | base OS + Docker daemon hardening |
| Kubernetes node | `k8s_nodes` | base OS + Kubernetes node hardening |
| PostgreSQL server | `db_nodes` | base OS + PostgreSQL hardening |
| Nginx web server | `web_nodes` | base OS + Nginx hardening |

- A server outside these groups is never touched.
- Put each server in **one** of these groups (see [limits](#decisions-and-limits-worth-knowing)).
- The group also tunes the base OS part. Docker and Kubernetes nodes keep IP forwarding on and `/tmp` executable,
  Kubernetes nodes open the cluster ports, web nodes open HTTP and HTTPS, and db nodes open PostgreSQL to the networks
  in `postgres_allowed_sources`. Docker, Kubernetes and database servers keep their main packages out of automatic updates.
- Optional group `k8s_control_plane`: nodes that also open the API server and etcd ports. Without it, every
  Kubernetes node is treated as a control-plane node.
- The PostgreSQL, Nginx and Docker roles do nothing on a server where that software is not installed. The Kubernetes
  role always runs on `k8s_nodes` (kernel modules, swap off).

## 2. Pick a playbook

| Playbook | Runs on | Does |
|---|---|---|
| `site.yml` | all groups | base OS, then each workload that matches the server, then the audit |
| `playbooks/base_os.yml` | all groups | base OS only |
| `playbooks/docker_host.yml` | `docker_nodes` | Docker only |
| `playbooks/k8s_node.yml` | `k8s_nodes` | Kubernetes node only, one node at a time |
| `playbooks/database_server.yml` | `db_nodes` | PostgreSQL only |
| `playbooks/web_server.yml` | `web_nodes` | Nginx only |
| `playbooks/audit_compliance.yml` | all groups | read-only audit, writes `reports/audit-<time>.html` and `.json` |
| `playbooks/security_scan.yml` | all groups | read-only scan (SUID, world-writable and unowned files, capabilities, changed package files, listening ports), writes `reports/scan-<time>.json` |

The workload playbooks do not include the base OS part. One command can take several playbooks; they run in order.
`site.yml` does not run the scan.

## 3. Narrow it down

Add any of these to a command. They combine freely.

| Option | Effect |
|---|---|
| `--limit srv-db-01` | one server |
| `--limit db_nodes` | one group |
| `--limit srv-db-01,web_nodes` | several servers and groups |
| `--tags auth,network` | only these controls (see [tags](#4-tags)) |
| `--skip-tags tmp_devshm_hardening` | everything except these controls |
| `--check --diff` | dry run: show what would change, change nothing (see [limits](#decisions-and-limits-worth-knowing)) |
| `-e hardening_serial=1` | servers per batch, default `25%`; a failure stops the run before the next batch |
| `-e hardening_k8s_serial=2` | the same for Kubernetes nodes, default `1` |
| `-e postgres_allow_restart=true` | allow a PostgreSQL restart when a setting needs one |
| `-e docker_allow_restart=true` | allow a Docker restart to apply `daemon.json` |
| `-e audit_min_score=90` | fail the audit for any server that scores below 90% |
| `-e aide_enabled=true` | any simple setting from `group_vars`, for this run only; it wins over every group |
| `--list-hosts`, `--list-tasks`, `--list-tags` | show what would run, without connecting to the servers |

## 4. Tags

| Tag | Runs |
|---|---|
| `packages` | legacy package removal, hardening tools, automatic security updates |
| `os_baseline` | kernel modules, sysctl, core dumps, shell timeout, umask, unused services, AppArmor, time sync, DNS, `/tmp` and `/dev/shm` |
| `auth` | your SSH keys, root password lock, PAM, password aging, sudo, login banners |
| `filesystem` | sensitive file permissions, home directories, SUID bits, cron and at, service account shells |
| `network` | firewall, fail2ban, SSH server config |
| `logging` | rsyslog, journald, auditd, log file permissions, AIDE |
| `ssh` | your SSH keys and the SSH server config |
| `docker`, `k8s`, `postgres`, `nginx` | the workload role |
| `audit`, `scan` | the read-only playbooks |
| any role name | that role only, e.g. `ufw_firewall` or `pam_hardening` (all roles are listed in [What it does](#what-it-does)) |

The preflight checks always run, whatever tags you pick.

## 5. Common combinations

```bash
# Everything on every server
ansible-playbook -J site.yml --check --diff          # dry run
ansible-playbook -J site.yml

# One kind of server: base OS + its workload + audit
ansible-playbook -J site.yml --limit standalone
ansible-playbook -J site.yml --limit db_nodes
ansible-playbook -J site.yml --limit web_nodes
ansible-playbook -J site.yml --limit k8s_nodes
ansible-playbook -J site.yml --limit docker_nodes

# One server, or a few: each one gets what its group needs
ansible-playbook -J site.yml --limit srv-db-01
ansible-playbook -J site.yml --limit srv-db-01,srv-web-01

# Base OS + one workload, without the audit
ansible-playbook -J playbooks/base_os.yml playbooks/database_server.yml --limit db_nodes
ansible-playbook -J playbooks/base_os.yml playbooks/web_server.yml --limit web_nodes

# Base OS only
ansible-playbook -J playbooks/base_os.yml

# Only the workload part (the base OS was applied before)
ansible-playbook -J playbooks/database_server.yml
ansible-playbook -J playbooks/k8s_node.yml

# Only some controls
ansible-playbook -J playbooks/base_os.yml --tags ssh               # install your keys, apply the SSH config
ansible-playbook -J playbooks/base_os.yml --tags auth,network
ansible-playbook -J playbooks/base_os.yml --tags ufw_firewall --limit srv-web-01
ansible-playbook -J site.yml --skip-tags tmp_devshm_hardening

# One server at a time
ansible-playbook -J site.yml -e hardening_serial=1

# Maintenance window: allow restarts
ansible-playbook -J playbooks/database_server.yml --limit srv-db-01 -e postgres_allow_restart=true
ansible-playbook -J playbooks/docker_host.yml --limit srv-docker-01 -e docker_allow_restart=true

# Read-only
ansible-playbook -J playbooks/audit_compliance.yml
ansible-playbook -J playbooks/audit_compliance.yml --limit db_nodes -e audit_min_score=90
ansible-playbook -J playbooks/security_scan.yml --limit srv-db-01

# Preview
ansible-playbook -J site.yml --limit srv-db-01 --list-hosts
ansible-playbook -J playbooks/base_os.yml --tags network --list-tasks
```

## 6. Step-by-step workflows

**Add a new server**

1. `ansible-vault edit inventory.ini` and add the server under its group.
2. `ansible -J srv-new-01 -m ping`
3. Take a snapshot if it is a VM.
4. `ansible-playbook -J site.yml --limit srv-new-01`
5. Open the audit report in `reports/`.

**First run on a production server**

1. `ansible-playbook -J playbooks/security_scan.yml --limit srv-db-01` and read `listening_sockets` in the report.
   Every port that clients use must be allowed, or the firewall cuts them off when it turns on.
2. Allow those ports: `postgres_allowed_sources` for PostgreSQL, `hardening_mgmt_cidrs` for SSH, `ufw_monitoring_cidrs`
   for metrics, `ufw_rules` for ports every server needs, and `ufw_rules_extra` in `group_vars/<group>.yml` for one group.
3. Take a snapshot or a backup.
4. In a maintenance window: `ansible-playbook -J site.yml --limit srv-db-01`
5. Check that you can still log in and that clients still connect, then read the audit.
6. Reboot and run step 4 again. It should report zero changes. The reboot activates the `/tmp` mount and the
   kernel module blacklist.

**Change a setting later**

1. Edit `group_vars/all.yml`, or `group_vars/<group>.yml` for one group.
2. Dry run only that role: `ansible-playbook -J playbooks/base_os.yml --tags <role> --check --diff`
   (use the workload playbook for workload settings).
3. Apply it: the same command without `--check --diff`.
4. `ansible-playbook -J playbooks/audit_compliance.yml`

**Switch SSH to keys**

1. Put your public key in `ssh_authorized_keys`, then `ansible-playbook -J playbooks/base_os.yml --tags ssh_authorized_keys`
2. Test it: `ssh -o PasswordAuthentication=no admin@<server>`
3. `ansible-vault edit inventory.ini`: remove `ansible_ssh_pass`, keep `ansible_become_password` (sudo needs it).
4. Set `ssh_password_authentication: "no"`, then `ansible-playbook -J playbooks/base_os.yml --tags ssh`

## Configuration

Everything is tuned in **`group_vars/all.yml`** (one commented file), and the audit checks hosts against the same
values. Workload differences are small overrides in `group_vars/<group>.yml`; `sysctl_overrides` changes single kernel
keys. There is nothing to configure inside roles.

Settings you will most likely touch: `ssh_authorized_keys`, `hardening_mgmt_cidrs`, `ssh_*`, `ufw_rules_extra` (per group),
`postgres_allowed_sources`, `chrony_servers`, `login_banner_text`, `audit_min_score`.

## What it does

| Area | Roles |
|---|---|
| Packages | `pkg_remove_legacy`, `pkg_install_hardening_tools`, `pkg_unattended_upgrades` |
| OS baseline | `kernel_module_blacklist`, `sysctl_hardening`, `coredump_disable`, `shell_tmout`, `umask_hardening`, `services_disable`, `apparmor_enforce`, `ntp_hardening`, `dns_resolver_hardening`, `tmp_devshm_hardening` |
| Authentication | `ssh_authorized_keys` (your public keys), `root_lockout`, `pam_hardening` (quality, lockout, history), `password_aging`, `sudo_hardening`, `login_banners`, `ssh_hardening` |
| Files & accounts | `sensitive_file_perms`, `home_dir_perms`, `suid_strip_nonessential`, `cron_at_restriction`, `service_account_hardening`, `log_file_perms` |
| Network | `ufw_firewall`, `fail2ban` |
| Logging | `rsyslog_hardening`, `journald_hardening`, `auditd_rules`, `aide_baseline` (opt-in) |
| Workloads | `docker_daemon_hardening`, `k8s_node_hardening`, `postgres_hardening`, `nginx_hardening` |
| Read-only | `compliance_audit`, `security_scan` |

## Safety design

- **Preflight**: supported OS, systemd, non-root connection user, sane policy values, free disk.
- **No lockouts**: SSH refuses to apply if it would cut off the connection user; the firewall allows SSH *before*
  default-deny is enabled; after an SSH change a brand-new login is opened to prove it still works.
- **Validate, then apply, else roll back**: `sshd -t`, `visudo -c`, `nginx -t`, `fail2ban-client --test`, `dockerd --validate`,
  PostgreSQL's own `pg_file_settings`, and a post-check of the PAM stack.
- **Failures are failures**: nothing is swallowed. A failing host stops the rollout before the next batch.
  Handlers still run after a failure (`force_handlers`), and sysctl compares live values, so an interrupted run heals on the next.
- **No surprise restarts**: Docker and PostgreSQL are not restarted unless `docker_allow_restart` / `postgres_allow_restart` are set.
- **No blind mass changes**: file scans are report-only; `/tmp` becomes tmpfs through fstab (next boot) instead of being mounted over a live directory.

## Reading the audit

Each check is `PASS` (matches the policy), `FAIL` (does not; the title says what was expected) or `SKIP` (not
applicable, e.g. Docker checks on a host without Docker). The score is PASS / (PASS + FAIL); SKIPs are excluded.
Set `audit_min_score` to fail the run below a threshold. Reports land in `reports/` (git-ignored).

## Testing

`make test` (`tests/run.sh`) builds an Ubuntu 24.04 container with systemd and sshd and connects like a real host
(SSH + password + sudo). It applies the hardening, applies it again and expects **zero changes**, runs `--check`,
runs the Nginx/PostgreSQL plays, runs the audit, and confirms the user can still log in. `make lint` runs yamllint and
ansible-lint (production profile). Containers cannot run auditd, AppArmor or load kernel modules, so those are skipped
there (`hardening_is_container`) and are the only expected audit failures.

## Decisions and limits worth knowing

- **One workload group per server.** When a server is in two workload groups, settings that both groups define
  (firewall rules, the automatic-update blacklist) come from only one of them, the one later in the alphabet. A server
  that is both a database and a web server loses its PostgreSQL firewall rule. Until this is fixed, keep each server in one group.
- **A dry run needs a server that was hardened once.** Check mode installs nothing, so on a fresh server the dry run
  stops at the PAM check, which looks for changes that were never made. Do the first run for real, on a snapshot.
- **SSH password login is currently on**, because the inventory logs in with a password. See
  [Switch SSH to keys](#6-step-by-step-workflows). The play refuses `ssh_password_authentication: "no"` while Ansible
  still logs in with a password, unless `hardening_mgmt_cidrs` keeps password login possible from your network.
- **`/tmp` and `/dev/shm` are `noexec`** (CIS). Docker and k8s profiles drop `noexec` on `/tmp`. A new `/tmp` tmpfs applies at next boot.
- **Ports published by Docker bypass UFW.** Bind to `127.0.0.1` or restrict them in the `DOCKER-USER` chain.
- **Kubernetes hardening is node-level** (kernel modules, sysctls, swap, file permissions, firewall). Kubelet flags and
  cluster components are left to your cluster tooling.
- `auditd_immutable: true` locks audit rules until reboot; enable only for a final lock-down.
- `udf` is blacklisted (CIS) but some clouds need it to provision; remove it with `kernel_blacklist_exclude`.
- The first run prints a harmless `remote_tmp ... did not exist` warning per user.

New role: `scripts/new_module.sh <name>` scaffolds one with these conventions.
