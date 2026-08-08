# Ubuntu 24.04 Hardening — Production Ansible Framework

A modular, idempotent, and workload-aware Ansible framework designed to harden Ubuntu 24.04 LTS environments across **Standalone**, **Docker**, and **Kubernetes** server nodes.

Each security control is implemented as an independent, self-contained Ansible role equipped with error handling (`block/rescue`) so individual control warnings never block full playbook execution.

---

## 📖 Operational Documentation

- **[Operations & Execution Guide](file:///Users/amritpoudel/linux-hardening/docs/EXECUTION_GUIDE.md)** — Step-by-step commands for running playbooks, targeted tags, Vault setup, dry-runs, and workload profiles.
- **[Project Architecture Reference](file:///Users/amritpoudel/linux-hardening/project_structure.md)** — Directory structure conventions and variable scoping guidelines.

---

## ⚡ Quick Start

```bash
# 1. Copy and configure inventory
cp inventory.example.ini inventory.ini

# 2. Dry-run audit check
ansible-playbook -i inventory.ini site.yml --check --diff

# 3. Apply full hardening
ansible-playbook -i inventory.ini site.yml

# 4. Apply specific category or tag
ansible-playbook -i inventory.ini site.yml --tags network
ansible-playbook -i inventory.ini site.yml --tags ssh_hardening
```

---

## 🛡️ Workload Profiles (Docker & Kubernetes Safety)

Hardening controls such as disabling `ip_forward`, blacklisting bridge/overlay kernel modules, aggressive UFW drop rules, or mounting `/tmp` with `noexec` can break container runtimes and Kubernetes pod communication.

This framework handles this via workload group profiles:
- `group_vars/all.yml`: Strict baseline for standalone Linux servers.
- `group_vars/docker_nodes.yml`: Preserves cgroups, Docker daemon networking, and container bridge options.
- `group_vars/k8s_nodes.yml`: Preserves `br_netfilter`, `ip_forward`, Kubelet/API/Etcd ports, and pod CNI overlay communication.

---

## 📊 Module Index (57 Production Controls)

| # | Module Role | Category | Primary Function |
|---|-------------|----------|------------------|
| 01 | [pkg_remove_legacy](file:///Users/amritpoudel/linux-hardening/roles/pkg_remove_legacy) | OS Baseline | Removes telnet, rsh, xinetd, tftp packages |
| 02 | [pkg_install_hardening_tools](file:///Users/amritpoudel/linux-hardening/roles/pkg_install_hardening_tools) | OS Baseline | Installs auditd, ufw, fail2ban, aide, debsums |
| 03 | [pkg_unattended_upgrades](file:///Users/amritpoudel/linux-hardening/roles/pkg_unattended_upgrades) | OS Baseline | Configures automatic security updates |
| 04 | [pkg_kernel_module_blacklist](file:///Users/amritpoudel/linux-hardening/roles/pkg_kernel_module_blacklist) | OS Baseline | Blacklists vulnerable kernel network modules |
| 05 | [kernel_unused_fs_disable](file:///Users/amritpoudel/linux-hardening/roles/kernel_unused_fs_disable) | OS Baseline | Disables cramfs, hfs, jffs2, freevxfs, udf |
| 06 | [sysctl_hardening](file:///Users/amritpoudel/linux-hardening/roles/sysctl_hardening) | OS Baseline | Sysctl network stack & memory protection |
| 07 | [ipv6_disable](file:///Users/amritpoudel/linux-hardening/roles/ipv6_disable) | OS Baseline | Hardens/Disables IPv6 router advertisements |
| 08 | [proc_hidepid](file:///Users/amritpoudel/linux-hardening/roles/proc_hidepid) | OS Baseline | Restricts /proc process visibility |
| 09 | [tmp_devshm_hardening](file:///Users/amritpoudel/linux-hardening/roles/tmp_devshm_hardening) | OS Baseline | Mounts /tmp and /dev/shm with nodev,nosuid,noexec |
| 10 | [sticky_bit_tmp](file:///Users/amritpoudel/linux-hardening/roles/sticky_bit_tmp) | OS Baseline | Enforces sticky bit (1777) on temporary dirs |
| 11 | [coredump_disable](file:///Users/amritpoudel/linux-hardening/roles/coredump_disable) | OS Baseline | Disables core dumps via limits & systemd |
| 12 | [shell_tmout](file:///Users/amritpoudel/linux-hardening/roles/shell_tmout) | OS Baseline | Sets 15-minute auto-logout on interactive shells |
| 13 | [user_group_audit](file:///Users/amritpoudel/linux-hardening/roles/user_group_audit) | Authentication | Audits /etc/passwd and /etc/shadow integrity |
| 14 | [root_lockout](file:///Users/amritpoudel/linux-hardening/roles/root_lockout) | Authentication | Locks direct root password login |
| 15 | [pam_pwquality](file:///Users/amritpoudel/linux-hardening/roles/pam_pwquality) | Authentication | Enforces password complexity rules |
| 16 | [pam_faillock](file:///Users/amritpoudel/linux-hardening/roles/pam_faillock) | Authentication | Locks user accounts after failed login attempts |
| 17 | [password_aging](file:///Users/amritpoudel/linux-hardening/roles/password_aging) | Authentication | Enforces password max age (90 days) |
| 18 | [pam_pwhistory](file:///Users/amritpoudel/linux-hardening/roles/pam_pwhistory) | Authentication | Prevents reuse of last 5 passwords |
| 19 | [sudo_hardening](file:///Users/amritpoudel/linux-hardening/roles/sudo_hardening) | Authentication | Enforces PTY allocation, sudo logging & timeout |
| 20 | [ssh_hardening](file:///Users/amritpoudel/linux-hardening/roles/ssh_hardening) | Authentication | Hardens OpenSSH daemon configuration |
| 21 | [ssh_hostkey_hardening](file:///Users/amritpoudel/linux-hardening/roles/ssh_hostkey_hardening) | Authentication | Restricts SSH host keys to Ed25519 / RSA 4096 |
| 22 | [login_banners](file:///Users/amritpoudel/linux-hardening/roles/login_banners) | Authentication | Sets legal warning banners on issue and motd |
| 23 | [sensitive_file_perms](file:///Users/amritpoudel/linux-hardening/roles/sensitive_file_perms) | Filesystem | Sets strict permissions on /etc/shadow, /etc/passwd |
| 24 | [home_dir_perms](file:///Users/amritpoudel/linux-hardening/roles/home_dir_perms) | Filesystem | Restricts home directory permissions to 0750 |
| 25 | [umask_hardening](file:///Users/amritpoudel/linux-hardening/roles/umask_hardening) | Filesystem | Enforces system umask 027 |
| 26 | [world_writable_scan](file:///Users/amritpoudel/linux-hardening/roles/world_writable_scan) | Filesystem | Strips world write permissions from files |
| 27 | [suid_sgid_audit](file:///Users/amritpoudel/linux-hardening/roles/suid_sgid_audit) | Filesystem | Audits SUID/SGID binaries |
| 28 | [unowned_file_scan](file:///Users/amritpoudel/linux-hardening/roles/unowned_file_scan) | Filesystem | Finds orphan files and assigns root ownership |
| 29 | [chattr_immutable_configs](file:///Users/amritpoudel/linux-hardening/roles/chattr_immutable_configs) | Filesystem | Applies chattr +i on key configuration files |
| 30 | [chattr_append_logs](file:///Users/amritpoudel/linux-hardening/roles/chattr_append_logs) | Filesystem | Applies chattr +a append-only on audit logs |
| 31 | [aide_baseline](file:///Users/amritpoudel/linux-hardening/roles/aide_baseline) | Filesystem | Initializes AIDE file integrity database |
| 32 | [network_exposure_audit](file:///Users/amritpoudel/linux-hardening/roles/network_exposure_audit) | Network | Audits listening TCP/UDP sockets |
| 33 | [ufw_default_policy](file:///Users/amritpoudel/linux-hardening/roles/ufw_default_policy) | Network | Enforces UFW Default Deny incoming firewall |
| 34 | [ufw_ssh_restriction](file:///Users/amritpoudel/linux-hardening/roles/ufw_ssh_restriction) | Network | Restricts UFW SSH access by IP/subnet |
| 35 | [ufw_allowed_services](file:///Users/amritpoudel/linux-hardening/roles/ufw_allowed_services) | Network | Opens application and Docker/K8s ports |
| 36 | [ufw_rate_limit_ssh](file:///Users/amritpoudel/linux-hardening/roles/ufw_rate_limit_ssh) | Network | Rate limits SSH connections in UFW |
| 37 | [ufw_logging](file:///Users/amritpoudel/linux-hardening/roles/ufw_logging) | Network | Enables UFW security logging |
| 38 | [fail2ban_ssh_jail](file:///Users/amritpoudel/linux-hardening/roles/fail2ban_ssh_jail) | Network | Bans IPs after 3 failed SSH attempts |
| 39 | [fail2ban_sudo_jail](file:///Users/amritpoudel/linux-hardening/roles/fail2ban_sudo_jail) | Network | Bans IPs/accounts after repeated sudo failures |
| 40 | [tcp_wrappers](file:///Users/amritpoudel/linux-hardening/roles/tcp_wrappers) | Network | Restricts /etc/hosts.allow and /etc/hosts.deny |
| 41 | [auditd_rules](file:///Users/amritpoudel/linux-hardening/roles/auditd_rules) | Network | Deploys CIS auditd rules monitoring system calls |
| 42 | [cron_at_restriction](file:///Users/amritpoudel/linux-hardening/roles/cron_at_restriction) | Additional | Restricts cron and at to root user |
| 43 | [securetty](file:///Users/amritpoudel/linux-hardening/roles/securetty) | Additional | Restricts direct root console login terminals |
| 44 | [log_file_perms](file:///Users/amritpoudel/linux-hardening/roles/log_file_perms) | Additional | Restricts permissions on /var/log files |
| 45 | [rsyslog_hardening](file:///Users/amritpoudel/linux-hardening/roles/rsyslog_hardening) | Additional | Configures rsyslog 0640 file creation mode |
| 46 | [journald_hardening](file:///Users/amritpoudel/linux-hardening/roles/journald_hardening) | Additional | Configures persistent compressed journal logs |
| 47 | [service_account_hardening](file:///Users/amritpoudel/linux-hardening/roles/service_account_hardening) | Additional | Sets nologin shell for daemon system users |
| 48 | [debsums_verification](file:///Users/amritpoudel/linux-hardening/roles/debsums_verification) | Additional | Verifies APT package binary signatures |
| 49 | [suid_strip_nonessential](file:///Users/amritpoudel/linux-hardening/roles/suid_strip_nonessential) | Additional | Strips SUID from chfn, chsh, gpasswd, newgrp |
| 50 | [systemd_service_hardening](file:///Users/amritpoudel/linux-hardening/roles/systemd_service_hardening) | Additional | Enforces systemd PrivateTmp defaults |
| 51 | [capability_audit](file:///Users/amritpoudel/linux-hardening/roles/capability_audit) | Additional | Audits Linux file capabilities |
| 52 | [hosts_equiv_removal](file:///Users/amritpoudel/linux-hardening/roles/hosts_equiv_removal) | Additional | Removes legacy .rhosts and hosts.equiv files |
| 53 | [issue_content](file:///Users/amritpoudel/linux-hardening/roles/issue_content) | Additional | Clears OS version details from issue banners |
| 54 | [dns_resolver_hardening](file:///Users/amritpoudel/linux-hardening/roles/dns_resolver_hardening) | Additional | Hardens systemd-resolved DNSSEC and DNS-over-TLS |
| 55 | [ntp_hardening](file:///Users/amritpoudel/linux-hardening/roles/ntp_hardening) | Additional | Installs and configures Chrony time sync |
| 56 | [compiler_restriction](file:///Users/amritpoudel/linux-hardening/roles/compiler_restriction) | Additional | Restricts GCC/Clang compilers to root |
| 57 | [boot_perms](file:///Users/amritpoudel/linux-hardening/roles/boot_perms) | Additional | Restricts permissions on /boot/grub/grub.cfg |
