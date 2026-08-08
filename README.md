# Ubuntu 24.04 Hardening — Production Ansible Framework

A modular, idempotent, and workload-aware Ansible framework engineered to harden Ubuntu 24.04 LTS environments across **Base OS**, **Docker Hosts**, **Kubernetes Nodes**, **PostgreSQL Databases**, and **Nginx Web Servers** with automated **CIS Compliance Reporting**.

---

## 📋 Table of Contents

- [Project Philosophy & Architecture](#-project-philosophy--architecture)
- [Requirements](#-requirements)
- [Project Directory Structure](#-project-directory-structure)
- [Workload Profiles & Safety Safeguards](#-workload-profiles--safety-safeguards)
- [Detailed Usage & Command Reference](#-detailed-usage--command-reference)
  - [1. Inventory Configuration & Vault Encryption](#1-inventory-configuration--vault-encryption)
  - [2. Non-Disruptive Security Audit Scanning](#2-non-disruptive-security-audit-scanning)
  - [3. Running Full Fleet Hardening Playbook](#3-running-full-fleet-hardening-playbook)
  - [4. Running Specialized Workload Playbooks](#4-running-specialized-workload-playbooks)
  - [5. Running Category-Level Hardening](#5-running-category-level-hardening)
  - [6. Running Specific Individual Roles or a Subset of Roles](#6-running-specific-individual-roles-or-a-subset-of-roles)
  - [7. Limiting Execution to Specific Target Hosts](#7-limiting-execution-to-specific-target-hosts)
  - [8. Dry-Run Audit Mode (Check & Diff)](#8-dry-run-audit-mode-check--diff)
  - [9. Scaffolding New Hardening Modules](#9-scaffolding-new-hardening-modules)
- [Complete 61-Module Role Index & Tag Reference](#-complete-61-module-role-index--tag-reference)
- [Audit Reports & Compliance Scoring](#-audit-reports--compliance-scoring)
- [Rollback & Troubleshooting Philosophy](#-rollback--troubleshooting-philosophy)

---

## 🎯 Project Philosophy & Architecture

Each security control is implemented as an **independent, self-contained Ansible role**.

Key architectural principles:
1. **Idempotency**: Playbooks inspect state before applying mutations. Re-running a playbook against an already-hardened node results in zero unnecessary changes (`changed=0`).
2. **Error Isolation (`block/rescue`)**: Every task block is wrapped in Ansible `block/rescue` structures. If a single control fails on a target host due to environment quirks, it logs a warning but **never halts** the execution of remaining hardening roles.
3. **Default OS State Awareness**: Roles verify whether settings already match Ubuntu 24.04 defaults or compliance targets before mutating files.
4. **Workload Safety**: Hardening rules that interfere with container engines, CNI overlay networks, or databases are dynamically adapted using Ansible group variables.

---

## 💻 Requirements

| Requirement | Supported Version / Notes |
|---|---|
| **Control Node OS** | Linux / macOS |
| **Python** | 3.10+ |
| **Ansible** | 2.16+ (`ansible-core`) |
| **Ansible Collections** | `ansible.posix`, `community.general` |
| **Target Host OS** | Ubuntu 24.04 LTS |
| **Privilege Escalation** | `become: true` (sudo/root access) |

Install required Ansible collections:
```bash
ansible-galaxy collection install ansible.posix community.general
```

---

## 📂 Project Directory Structure

```
linux-hardening/
├── ansible.cfg                      # Global project settings & SSH connection tuning
├── site.yml                         # Master fleet orchestrator playbook
├── inventory.ini                    # Production host inventory (Gitignored)
├── inventory.example.ini            # Sanitized inventory template (Committed)
├── docs/
│   └── EXECUTION_GUIDE.md           # Step-by-step operations manual
├── group_vars/
│   ├── all.yml                      # Global baseline variables & default toggles
│   ├── docker_nodes.yml             # Docker host workload overrides
│   └── k8s_nodes.yml                # Kubernetes node workload overrides
├── playbooks/
│   ├── audit_compliance.yml         # Standalone non-disruptive CIS audit playbook
│   ├── base_os.yml                  # Base OS baseline hardening playbook
│   ├── docker_host.yml              # Docker daemon & container engine playbook
│   ├── k8s_node.yml                 # Kubelet & Kubernetes node benchmark playbook
│   ├── database_server.yml          # PostgreSQL database hardening playbook
│   └── web_server.yml               # Nginx web server hardening playbook
├── reports/                         # Generated JSON & HTML compliance audit reports
├── scripts/
│   └── new_module.sh                # Role scaffolding generator script
└── roles/                           # 61 independent hardening roles
    ├── 01_pkg_remove_legacy/
    ├── 02_pkg_install_hardening_tools/
    ├── ...
    └── nginx_hardening/
```

---

## 🛡️ Workload Profiles & Safety Safeguards

Applying aggressive security controls (like `sysctl net.ipv4.ip_forward = 0`, blacklisting `bridge` modules, or restrictive UFW rules) can break container runtimes and Kubernetes pod communication.

This framework solves this using **Workload Profiles**:
- **[group_vars/all.yml](file:///Users/amritpoudel/linux-hardening/group_vars/all.yml)**: Strict baseline for standalone Linux servers.
- **[group_vars/docker_nodes.yml](file:///Users/amritpoudel/linux-hardening/group_vars/docker_nodes.yml)**: Preserves cgroups, Docker daemon networking (`userland-proxy`, `icc`), and container bridge options.
- **[group_vars/k8s_nodes.yml](file:///Users/amritpoudel/linux-hardening/group_vars/k8s_nodes.yml)**: Preserves `br_netfilter`, `ip_forward`, Kubelet/API/Etcd ports, and pod CNI overlay communication.

---

## 📖 Detailed Usage & Command Reference

### 1. Inventory Configuration & Vault Encryption

Copy the example inventory template to create your working `inventory.ini`:
```bash
cp inventory.example.ini inventory.ini
```

Edit `inventory.ini` to assign target IP addresses into appropriate workload groups:
```ini
[standalone]
srv-app-01 ansible_host=10.0.0.10 ansible_user=admin

[docker_nodes]
srv-docker-01 ansible_host=10.0.0.20 ansible_user=admin

[k8s_nodes]
k8s-node-01 ansible_host=10.0.0.30 ansible_user=admin

[db_nodes]
srv-db-01 ansible_host=10.0.0.40 ansible_user=admin

[web_nodes]
srv-web-01 ansible_host=10.0.0.50 ansible_user=admin
```

#### Encrypting Passwords with Ansible Vault
```bash
# Encrypt inventory containing passwords
ansible-vault encrypt inventory.ini

# Edit encrypted inventory
ansible-vault edit inventory.ini

# Run playbook with vault prompt
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

---

### 2. Non-Disruptive Security Audit Scanning

To scan target servers, calculate compliance scores, and generate **HTML** and **JSON** reports without altering any system settings:

```bash
ansible-playbook -i inventory.ini playbooks/audit_compliance.yml
```

Reports are saved to `reports/`:
- `reports/audit-report-<hostname>-<timestamp>.html`
- `reports/audit-report-<hostname>-<timestamp>.json`

---

### 3. Running Full Fleet Hardening Playbook

Executes Base OS hardening, technology-specific playbooks against their corresponding inventory groups, and finishes with a post-hardening compliance audit:

```bash
ansible-playbook -i inventory.ini site.yml
```

---

### 4. Running Specialized Workload Playbooks

Rather than running a single flat playbook across all nodes, run playbooks tailored to specific server responsibilities:

```bash
# Run Base OS hardening only (SSH, PAM, Sysctl, Filesystem, Auditd, UFW)
ansible-playbook -i inventory.ini playbooks/base_os.yml

# Run Docker engine hardening only
ansible-playbook -i inventory.ini playbooks/docker_host.yml

# Run Kubernetes node hardening only
ansible-playbook -i inventory.ini playbooks/k8s_node.yml

# Run PostgreSQL database hardening only
ansible-playbook -i inventory.ini playbooks/database_server.yml

# Run Nginx web server hardening only
ansible-playbook -i inventory.ini playbooks/web_server.yml
```

---

### 5. Running Category-Level Hardening

Use Ansible tags to run an entire category of hardening controls across all hosts:

```bash
# Run all Authentication & Identity controls (SSH, PAM, sudo, password aging, banners)
ansible-playbook -i inventory.ini site.yml --tags auth

# Run all OS Baseline controls (legacy removal, sysctl, proc hidepid, coredump)
ansible-playbook -i inventory.ini site.yml --tags os_baseline

# Run all Filesystem controls (permissions, umask, AIDE, world-writable scan)
ansible-playbook -i inventory.ini site.yml --tags filesystem

# Run all Network Security controls (UFW, Fail2ban, Auditd, TCP wrappers)
ansible-playbook -i inventory.ini site.yml --tags network

# Run all Additional Hardening controls (chrony, debsums, systemd, boot perms)
ansible-playbook -i inventory.ini site.yml --tags additional
```

---

### 6. Running Specific Individual Roles or a Subset of Roles

You can execute a **single role** or a **custom subset of 5, 10, or 20 specific roles** using comma-separated tags with `--tags`.

#### Example A: Run a single role (e.g. OpenSSH Hardening)
```bash
ansible-playbook -i inventory.ini site.yml --tags ssh_hardening
```

#### Example B: Run 3 specific network firewall roles
```bash
ansible-playbook -i inventory.ini site.yml --tags "ufw_default_policy,ufw_ssh_restriction,fail2ban_ssh_jail"
```

#### Example C: Run a selected subset of 10 specific security roles
```bash
ansible-playbook -i inventory.ini site.yml --tags "ssh_hardening,sudo_hardening,root_lockout,pam_pwquality,pam_faillock,ufw_default_policy,fail2ban_ssh_jail,auditd_rules,sysctl_hardening,tmp_devshm_hardening"
```

---

### 7. Limiting Execution to Specific Target Hosts

Use the `-l` or `--limit` flag to target a single host or host group:

```bash
# Target a single server by hostname/IP
ansible-playbook -i inventory.ini site.yml -l srv-docker-01

# Target Docker hosts group only
ansible-playbook -i inventory.ini site.yml -l docker_nodes

# Combine limit and tags (Run SSH hardening on DB servers only)
ansible-playbook -i inventory.ini site.yml -l db_nodes --tags ssh_hardening
```

---

### 8. Dry-Run Audit Mode (Check & Diff)

To simulate playbook execution and see exact file line diffs without modifying systems:

```bash
ansible-playbook -i inventory.ini site.yml --check --diff
```

---

### 9. Scaffolding New Hardening Modules

Use the generator script to create new role boilerplate in standard format:

```bash
./scripts/new_module.sh 62_redis_hardening
```
Generates `roles/62_redis_hardening/` containing `tasks/main.yml`, `vars/main.yml`, `handlers/main.yml`, `templates/`, and `README.md`.

---

## 📊 Complete 61-Module Role Index & Tag Reference

| # | Module Role | Category | Ansible Tag(s) | Primary Hardening Function |
|---|-------------|----------|----------------|----------------------------|
| 01 | [pkg_remove_legacy](file:///Users/amritpoudel/linux-hardening/roles/pkg_remove_legacy) | OS Baseline | `pkg_remove_legacy`, `os_baseline` | Purges inetutils-telnet, tftpd-hpa, xinetd, talk |
| 02 | [pkg_install_hardening_tools](file:///Users/amritpoudel/linux-hardening/roles/pkg_install_hardening_tools) | OS Baseline | `pkg_install_hardening_tools`, `os_baseline` | Installs auditd, ufw, fail2ban, aide, debsums, apparmor |
| 03 | [pkg_unattended_upgrades](file:///Users/amritpoudel/linux-hardening/roles/pkg_unattended_upgrades) | OS Baseline | `pkg_unattended_upgrades`, `os_baseline` | Configures unattended-upgrades for auto patch management |
| 04 | [pkg_kernel_module_blacklist](file:///Users/amritpoudel/linux-hardening/roles/pkg_kernel_module_blacklist) | OS Baseline | `pkg_kernel_module_blacklist`, `os_baseline` | Blacklists dccp, sctp, rds, tipc kernel modules |
| 05 | [kernel_unused_fs_disable](file:///Users/amritpoudel/linux-hardening/roles/kernel_unused_fs_disable) | OS Baseline | `kernel_unused_fs_disable`, `os_baseline` | Disables cramfs, freevxfs, jffs2, hfs, hfsplus, udf |
| 06 | [sysctl_hardening](file:///Users/amritpoudel/linux-hardening/roles/sysctl_hardening) | OS Baseline | `sysctl_hardening`, `os_baseline`, `sysctl` | Sysctl ASLR, SYN cookies, RP filter, ICMP redirect disable |
| 07 | [ipv6_disable](file:///Users/amritpoudel/linux-hardening/roles/ipv6_disable) | OS Baseline | `ipv6_disable`, `os_baseline` | Hardens/Disables IPv6 router advertisements |
| 08 | [proc_hidepid](file:///Users/amritpoudel/linux-hardening/roles/proc_hidepid) | OS Baseline | `proc_hidepid`, `os_baseline` | Mounts /proc with hidepid=2 to restrict process visibility |
| 09 | [tmp_devshm_hardening](file:///Users/amritpoudel/linux-hardening/roles/tmp_devshm_hardening) | OS Baseline | `tmp_devshm_hardening`, `os_baseline` | Mounts /tmp and /dev/shm with nodev, nosuid, noexec |
| 10 | [sticky_bit_tmp](file:///Users/amritpoudel/linux-hardening/roles/sticky_bit_tmp) | OS Baseline | `sticky_bit_tmp`, `os_baseline` | Enforces sticky bit (1777) on /tmp and /var/tmp |
| 11 | [coredump_disable](file:///Users/amritpoudel/linux-hardening/roles/coredump_disable) | OS Baseline | `coredump_disable`, `os_baseline` | Disables core dumps via limits.conf & systemd |
| 12 | [shell_tmout](file:///Users/amritpoudel/linux-hardening/roles/shell_tmout) | OS Baseline | `shell_tmout`, `os_baseline` | Sets 15-minute TMOUT auto-logout on interactive shells |
| 13 | [user_group_audit](file:///Users/amritpoudel/linux-hardening/roles/user_group_audit) | Authentication | `user_group_audit`, `auth` | Verifies integrity of /etc/passwd, /etc/shadow using pwck |
| 14 | [root_lockout](file:///Users/amritpoudel/linux-hardening/roles/root_lockout) | Authentication | `root_lockout`, `auth` | Locks root password account, forcing sudo access |
| 15 | [pam_pwquality](file:///Users/amritpoudel/linux-hardening/roles/pam_pwquality) | Authentication | `pam_pwquality`, `auth`, `pam` | Enforces password complexity (minlen=14, 4 classes) |
| 16 | [pam_faillock](file:///Users/amritpoudel/linux-hardening/roles/pam_faillock) | Authentication | `pam_faillock`, `auth`, `pam` | Locks accounts for 15 min after 5 failed login attempts |
| 17 | [password_aging](file:///Users/amritpoudel/linux-hardening/roles/password_aging) | Authentication | `password_aging`, `auth` | Sets PASS_MAX_DAYS 90, PASS_MIN_DAYS 7 in login.defs |
| 18 | [pam_pwhistory](file:///Users/amritpoudel/linux-hardening/roles/pam_pwhistory) | Authentication | `pam_pwhistory`, `auth`, `pam` | Prevents reuse of last 5 passwords via pam_pwhistory.so |
| 19 | [sudo_hardening](file:///Users/amritpoudel/linux-hardening/roles/sudo_hardening) | Authentication | `sudo_hardening`, `auth`, `sudo` | Enforces use_pty, sudo logfile (/var/log/sudo.log), 5m timeout |
| 20 | [ssh_hardening](file:///Users/amritpoudel/linux-hardening/roles/ssh_hardening) | Authentication | `ssh_hardening`, `auth`, `ssh` | Hardens OpenSSH daemon (disables root, X11, strict ciphers) |
| 21 | [ssh_hostkey_hardening](file:///Users/amritpoudel/linux-hardening/roles/ssh_hostkey_hardening) | Authentication | `ssh_hostkey_hardening`, `auth`, `ssh` | Restricts SSH host keys to Ed25519 and RSA 4096 |
| 22 | [login_banners](file:///Users/amritpoudel/linux-hardening/roles/login_banners) | Authentication | `login_banners`, `auth` | Sets legal warning banners in /etc/issue, issue.net, motd |
| 23 | [sensitive_file_perms](file:///Users/amritpoudel/linux-hardening/roles/sensitive_file_perms) | Filesystem | `sensitive_file_perms`, `filesystem` | Sets strict 0600/0644 perms on /etc/shadow, passwd, crontab |
| 24 | [home_dir_perms](file:///Users/amritpoudel/linux-hardening/roles/home_dir_perms) | Filesystem | `home_dir_perms`, `filesystem` | Restricts home directory permissions under /home to 0750 |
| 25 | [umask_hardening](file:///Users/amritpoudel/linux-hardening/roles/umask_hardening) | Filesystem | `umask_hardening`, `filesystem` | Enforces default system umask 027 in login.defs & profile |
| 26 | [world_writable_scan](file:///Users/amritpoudel/linux-hardening/roles/world_writable_scan) | Filesystem | `world_writable_scan`, `filesystem` | Scans and strips world-write bit (o-w) from files |
| 27 | [suid_sgid_audit](file:///Users/amritpoudel/linux-hardening/roles/suid_sgid_audit) | Filesystem | `suid_sgid_audit`, `filesystem` | Audits and logs SUID/SGID executables across filesystems |
| 28 | [unowned_file_scan](file:///Users/amritpoudel/linux-hardening/roles/unowned_file_scan) | Filesystem | `unowned_file_scan`, `filesystem` | Detects orphan files without valid owner and assigns to root |
| 29 | [chattr_immutable_configs](file:///Users/amritpoudel/linux-hardening/roles/chattr_immutable_configs) | Filesystem | `chattr_immutable_configs`, `filesystem` | Applies chattr +i on critical security configs when enabled |
| 30 | [chattr_append_logs](file:///Users/amritpoudel/linux-hardening/roles/chattr_append_logs) | Filesystem | `chattr_append_logs`, `filesystem` | Applies chattr +a append-only attribute on key system log files |
| 31 | [aide_baseline](file:///Users/amritpoudel/linux-hardening/roles/aide_baseline) | Filesystem | `aide_baseline`, `filesystem`, `aide` | Initializes AIDE file integrity monitoring baseline database |
| 32 | [network_exposure_audit](file:///Users/amritpoudel/linux-hardening/roles/network_exposure_audit) | Network | `network_exposure_audit`, `network` | Audits open listening sockets with ss -tulpn |
| 33 | [ufw_default_policy](file:///Users/amritpoudel/linux-hardening/roles/ufw_default_policy) | Network | `ufw_default_policy`, `network`, `ufw` | Enforces UFW Default Deny incoming firewall policy |
| 34 | [ufw_ssh_restriction](file:///Users/amritpoudel/linux-hardening/roles/ufw_ssh_restriction) | Network | `ufw_ssh_restriction`, `network`, `ufw` | Restricts SSH firewall access with optional IP subnet filtering |
| 35 | [ufw_allowed_services](file:///Users/amritpoudel/linux-hardening/roles/ufw_allowed_services) | Network | `ufw_allowed_services`, `network`, `ufw` | Opens application and Docker/K8s specific ports in UFW |
| 36 | [ufw_rate_limit_ssh](file:///Users/amritpoudel/linux-hardening/roles/ufw_rate_limit_ssh) | Network | `ufw_rate_limit_ssh`, `network`, `ufw` | Rate limits SSH port connection attempts in UFW |
| 37 | [ufw_logging](file:///Users/amritpoudel/linux-hardening/roles/ufw_logging) | Network | `ufw_logging`, `network`, `ufw` | Enables UFW security logging (logging medium) |
| 38 | [fail2ban_ssh_jail](file:///Users/amritpoudel/linux-hardening/roles/fail2ban_ssh_jail) | Network | `fail2ban_ssh_jail`, `network`, `fail2ban` | Bans IPs for 1 hour after 3 failed SSH authentication attempts |
| 39 | [fail2ban_sudo_jail](file:///Users/amritpoudel/linux-hardening/roles/fail2ban_sudo_jail) | Network | `fail2ban_sudo_jail`, `network`, `fail2ban` | Bans IPs/accounts after repeated sudo escalation failures |
| 40 | [tcp_wrappers](file:///Users/amritpoudel/linux-hardening/roles/tcp_wrappers) | Network | `tcp_wrappers`, `network` | Restricts /etc/hosts.allow and sets ALL: ALL in hosts.deny |
| 41 | [auditd_rules](file:///Users/amritpoudel/linux-hardening/roles/auditd_rules) | Network | `auditd_rules`, `network`, `auditd` | Deploys CIS auditd rules monitoring identity & sudo changes |
| 42 | [cron_at_restriction](file:///Users/amritpoudel/linux-hardening/roles/cron_at_restriction) | Additional | `cron_at_restriction`, `additional` | Restricts cron and at job scheduling to root user |
| 43 | [securetty](file:///Users/amritpoudel/linux-hardening/roles/securetty) | Additional | `securetty`, `additional` | Restricts direct root console login terminals to tty1 |
| 44 | [log_file_perms](file:///Users/amritpoudel/linux-hardening/roles/log_file_perms) | Additional | `log_file_perms`, `additional` | Enforces g-wx,o-rwx permissions on /var/log files |
| 45 | [rsyslog_hardening](file:///Users/amritpoudel/linux-hardening/roles/rsyslog_hardening) | Additional | `rsyslog_hardening`, `additional` | Configures rsyslog 0640 file creation mode |
| 46 | [journald_hardening](file:///Users/amritpoudel/linux-hardening/roles/journald_hardening) | Additional | `journald_hardening`, `additional` | Configures persistent compressed systemd journal log storage |
| 47 | [service_account_hardening](file:///Users/amritpoudel/linux-hardening/roles/service_account_hardening) | Additional | `service_account_hardening`, `additional` | Sets /usr/sbin/nologin shell for non-root system daemon accounts |
| 48 | [debsums_verification](file:///Users/amritpoudel/linux-hardening/roles/debsums_verification) | Additional | `debsums_verification`, `additional` | Verifies APT package binary integrity hashes using debsums |
| 49 | [suid_strip_nonessential](file:///Users/amritpoudel/linux-hardening/roles/suid_strip_nonessential) | Additional | `suid_strip_nonessential`, `additional` | Strips SUID bit from chfn, chsh, gpasswd, newgrp |
| 50 | [systemd_service_hardening](file:///Users/amritpoudel/linux-hardening/roles/systemd_service_hardening) | Additional | `systemd_service_hardening`, `additional` | Enforces systemd DefaultPrivateTmp=yes isolation |
| 51 | [capability_audit](file:///Users/amritpoudel/linux-hardening/roles/capability_audit) | Additional | `capability_audit`, `additional` | Audits Linux extended capabilities assigned to binaries |
| 52 | [hosts_equiv_removal](file:///Users/amritpoudel/linux-hardening/roles/hosts_equiv_removal) | Additional | `hosts_equiv_removal`, `additional` | Removes legacy rsh .rhosts and hosts.equiv trust files |
| 53 | [issue_content](file:///Users/amritpoudel/linux-hardening/roles/issue_content) | Additional | `issue_content`, `additional` | Clears OS version details from issue banners |
| 54 | [dns_resolver_hardening](file:///Users/amritpoudel/linux-hardening/roles/dns_resolver_hardening) | Additional | `dns_resolver_hardening`, `additional` | Hardens systemd-resolved DNSSEC and DNS-over-TLS |
| 55 | [ntp_hardening](file:///Users/amritpoudel/linux-hardening/roles/ntp_hardening) | Additional | `ntp_hardening`, `additional` | Installs and enables Chrony NTP time synchronization |
| 56 | [compiler_restriction](file:///Users/amritpoudel/linux-hardening/roles/compiler_restriction) | Additional | `compiler_restriction`, `additional` | Restricts GCC/Clang compilers to root execution (chmod 0700) |
| 57 | [boot_perms](file:///Users/amritpoudel/linux-hardening/roles/boot_perms) | Additional | `boot_perms`, `additional` | Restricts permissions on /boot/grub/grub.cfg to 0600 |
| 58 | [docker_daemon_hardening](file:///Users/amritpoudel/linux-hardening/roles/docker_daemon_hardening) | Containers | `docker_daemon`, `docker` | Hardens /etc/docker/daemon.json (icc:false, no-new-privileges) |
| 59 | [k8s_node_hardening](file:///Users/amritpoudel/linux-hardening/roles/k8s_node_hardening) | Kubernetes | `k8s_node`, `k8s`, `kubelet` | Disables swap, hardens Kubelet config and 0600 file perms |
| 60 | [postgres_hardening](file:///Users/amritpoudel/linux-hardening/roles/postgres_hardening) | Database | `postgres`, `database` | Forces PostgreSQL SSL, SCRAM-SHA-256, 0700 data dir perms |
| 61 | [nginx_hardening](file:///Users/amritpoudel/linux-hardening/roles/nginx_hardening) | Web Server | `nginx`, `webserver` | Hardens Nginx headers, server_tokens off, TLSv1.2/1.3 ciphers |

---

## 📈 Audit Reports & Compliance Scoring

When running `playbooks/audit_compliance.yml` or `site.yml`, the framework evaluates all checks and outputs:

1. **Terminal Console Output**:
   ```
   TASK [compliance_audit_reporter : Display Compliance Audit Score Summary] *********************
   ok: [target-server-01] => {
       "msg": "COMPLIANCE SCORE for target-server-01: 96.2% (26/27 Passed)"
   }
   ```
2. **JSON Machine Audit Log**:
   Saved to `reports/audit-report-<hostname>-<timestamp>.json` for ingestion into SIEM / Elastic / Splunk.
3. **HTML Interactive Dashboard**:
   Saved to `reports/audit-report-<hostname>-<timestamp>.html` featuring a dark-mode UI with pass/fail badges and remediation instructions.

---

## 🔄 Rollback & Troubleshooting Philosophy

Each role contains a `README.md` documenting specific rollback commands (e.g. reversing `sysctl`, restoring `sshd_config`, or re-enabling packages).

Because hardening controls are highly modular, undoing a change is granular:
- Revert a single role setting by modifying that role's `vars/main.yml` and re-running with `--tags <role_name>`.
- Always test new rules in a staging environment using `--check --diff` before deploying to production.
