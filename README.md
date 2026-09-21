# Ubuntu 24.04 hardening (Ansible)

Idempotent, check-mode-safe hardening for Ubuntu 24.04 servers: base OS, Docker hosts, Kubernetes nodes,
PostgreSQL and Nginx, plus a read-only compliance audit. Hosts live in one Ansible-Vault-encrypted `inventory.ini`.

## Requirements

- Control node: `ansible-core` 2.16+, `sshpass` (password logins), `make deps` for the collections
- Targets: Ubuntu 24.04 LTS, a non-root sudo user (root is refused by design)

## Quick start

```bash
cp inventory.example.ini inventory.ini     # first time only: hosts, users, passwords
ansible-vault encrypt inventory.ini        # (keep editing it later with: ansible-vault edit inventory.ini)
make deps                                  # ansible.posix, community.general

ansible-playbook site.yml --ask-vault-pass --check --diff   # dry run first
ansible-playbook site.yml --ask-vault-pass                  # harden everything, then audit
```

Groups decide what a host gets: **standalone / docker_nodes / k8s_nodes / db_nodes / web_nodes** all receive the
base OS hardening; the last four add their workload play. Optional group `k8s_control_plane` marks nodes that should
also open API/etcd ports (without it every k8s node is treated as control plane).

## Running parts

| Goal | Command (add `--ask-vault-pass`) |
|---|---|
| Base OS only | `ansible-playbook playbooks/base_os.yml` |
| One control | `ansible-playbook playbooks/base_os.yml --tags ssh_hardening` |
| Workloads | `playbooks/docker_host.yml`, `k8s_node.yml`, `database_server.yml`, `web_server.yml` |
| One host / group | `... --limit srv-web-01` |
| Rollout size | `-e hardening_serial=1` (default 25%; k8s nodes default to 1) |
| Audit (read-only) | `playbooks/audit_compliance.yml` → `reports/audit-<time>.html/.json` |
| Filesystem scan (read-only) | `playbooks/security_scan.yml` → `reports/scan-<time>.json` |

Tags are the role names plus `packages`, `os_baseline`, `auth`, `filesystem`, `network`, `logging`.

## Configuration

Everything is tuned in **`group_vars/all.yml`** (one commented file), and the audit checks hosts against the same
values. Workload differences are small overrides in `group_vars/<group>.yml`; `sysctl_overrides` changes single kernel
keys. There is nothing to configure inside roles.

Settings you will most likely touch: `hardening_mgmt_cidrs`, `ssh_*`, `ufw_rules_extra` (per group),
`postgres_allowed_sources`, `chrony_servers`, `login_banner_text`, `audit_min_score`.

## What it does

| Area | Roles |
|---|---|
| Packages | `pkg_remove_legacy`, `pkg_install_hardening_tools`, `pkg_unattended_upgrades` |
| OS baseline | `kernel_module_blacklist`, `sysctl_hardening`, `coredump_disable`, `shell_tmout`, `umask_hardening`, `services_disable`, `apparmor_enforce`, `ntp_hardening`, `dns_resolver_hardening`, `tmp_devshm_hardening` |
| Authentication | `root_lockout`, `pam_hardening` (quality, lockout, history), `password_aging`, `sudo_hardening`, `login_banners`, `ssh_hardening` |
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

## Changing the SSH port

A two-step move, so Ansible never loses its connection:

1. Run with `-e ssh_port=<new> -e ssh_allow_port_change=true`. The firewall opens the new port first, then sshd
   moves (through an `ssh.socket` override on Ubuntu 24.04). The play then tells you Ansible can no longer reach the old port.
2. Set `ansible_port=<new>` in the inventory, add the old port to `ufw_ssh_previous_ports` to close it, and re-run.

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

- **SSH password login is currently on** (the inventory authenticates with a password). `ssh_password_authentication: "no"`
  is refused until it is safe: switch the inventory to keys, or list your management network in `hardening_mgmt_cidrs`
  so password login stays possible only from there.
- **`/tmp` and `/dev/shm` are `noexec`** (CIS). Docker and k8s profiles drop `noexec` on `/tmp`. A new `/tmp` tmpfs applies at next boot.
- **Ports published by Docker bypass UFW.** Bind to `127.0.0.1` or restrict them in the `DOCKER-USER` chain.
- **Kubernetes hardening is node-level** (kernel modules, sysctls, swap, file permissions, firewall). Kubelet flags and
  cluster components are left to your cluster tooling.
- `auditd_immutable: true` locks audit rules until reboot; enable only for a final lock-down.
- `udf` is blacklisted (CIS) but some clouds need it to provision; remove it with `kernel_blacklist_exclude`.
- The first run prints a harmless `remote_tmp ... did not exist` warning per user.

New role: `scripts/new_module.sh <name>` scaffolds one with these conventions.
