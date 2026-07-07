# Ubuntu 24.04 Hardening — Ansible Project

A modular, idempotent Ansible project to harden Ubuntu 24.04 systems.
Each hardening control is implemented as an **independent role (module)** —
self-contained with its own tasks, variables, handlers, and documentation.
A failure in one module never blocks the rest of the run.


---

## Requirements

| Requirement       | Version / Notes            |
|--------------------|-----------------------------|
| Target OS          | Ubuntu 24.04 LTS            |
| Ansible            | 2.16+                       |
| Control node       | Linux/macOS, Python 3.10+   |
| Privilege          | `become: true` (sudo/root)  |

---

## Project Structure

```
ubuntu24-hardening/
├── ansible.cfg              # Single project-wide Ansible config
├── site.yml                 # Master playbook — runs all modules in order
├── inventory.ini            # Plain inventory (hosts to harden)
├── group_vars/
│   └── all.yml              # Global variables — apply to every module
├── README.md                # This file
└── roles/
    ├── 01_pkg_remove_legacy/
    ├── 02_pkg_install_hardening_tools/
    ├── 03_unattended_upgrades/
    ├── ...
    └── 57_boot_perms/
```

Each role follows the same internal layout:

```
roles/NN_module_name/
├── tasks/main.yml       # The actual work, wrapped in block/rescue
├── vars/main.yml        # Variables specific to this module only
├── handlers/main.yml    # Service restarts/reloads triggered by this module
├── templates/           # Jinja2 config templates (if any)
└── README.md            # What it does, commands run, rollback steps
```

**Rule of thumb:** if a variable, template, or handler is used by only one
module, it lives inside that module's folder. If it applies to the entire
project (e.g. log directory, report path), it lives in `group_vars/all.yml`.

---

## Usage

### 1. Configure inventory
Edit `inventory.ini` with the target host(s):
```ini
[hardening_targets]
target-host ansible_host=192.168.1.10 ansible_user=admin
```

### 2. Review global variables
Edit `group_vars/all.yml` for shared settings (log paths, report location, etc).

### 3. Review module-specific variables
Each role's `vars/main.yml` holds tunables for that control only
(e.g. allowed SSH ciphers, password history depth, admin IP allowlist).
Adjust before running if the defaults don't fit your environment.

### 4. Run the full hardening playbook
```bash
ansible-playbook -i inventory.ini site.yml
```

### 5. Run a single module (by tag)
```bash
ansible-playbook -i inventory.ini site.yml --tags ssh_hardening
```

### 6. Run a category of modules
```bash
ansible-playbook -i inventory.ini site.yml --tags network
```

### 7. Check the run report
Every run writes a summary to `reports/run-<timestamp>.log` listing each
module's status: `OK`, `CHANGED`, `FAILED`, or `SKIPPED`. A failed module
never halts the play — check the report afterward for anything that
needs manual follow-up.

---

## Secrets

No secrets are stored by default. If a module later needs to handle
sensitive data (e.g. an admin IP allowlist you'd rather not commit in
plaintext), encrypt that module's `vars/main.yml` directly with:
```bash
ansible-vault encrypt roles/NN_module_name/vars/main.yml
```
and run the playbook with `--ask-vault-pass` or `--vault-password-file`.

---

## Module Index

| # | Module | Category |
|---|--------|----------|
| 01 | pkg_remove_legacy | OS Baseline |
| 02 | pkg_install_hardening_tools | OS Baseline |
| 03 | unattended_upgrades | OS Baseline |
| 04 | kernel_module_blacklist | OS Baseline |
| 05 | kernel_unused_fs_disable | OS Baseline |
| 06 | sysctl_hardening | OS Baseline |
| 07 | ipv6_disable | OS Baseline |
| 08 | proc_hidepid | OS Baseline |
| 09 | tmp_devshm_hardening | OS Baseline |
| 10 | sticky_bit_tmp | OS Baseline |
| 11 | coredump_disable | OS Baseline |
| 12 | shell_tmout | OS Baseline |
| 13 | user_group_audit | Authentication & Identity |
| 14 | root_lockout | Authentication & Identity |
| 15 | pam_pwquality | Authentication & Identity |
| 16 | pam_faillock | Authentication & Identity |
| 17 | password_aging | Authentication & Identity |
| 18 | pam_pwhistory | Authentication & Identity |
| 19 | sudo_hardening | Authentication & Identity |
| 20 | ssh_hardening | Authentication & Identity |
| 21 | ssh_hostkey_hardening | Authentication & Identity |
| 22 | login_banners | Authentication & Identity |
| 23 | sensitive_file_perms | Filesystem |
| 24 | home_dir_perms | Filesystem |
| 25 | umask_hardening | Filesystem |
| 26 | world_writable_scan | Filesystem |
| 27 | suid_sgid_audit | Filesystem |
| 28 | unowned_file_scan | Filesystem |
| 29 | chattr_immutable_configs | Filesystem |
| 30 | chattr_append_logs | Filesystem |
| 31 | aide_baseline | Filesystem |
| 32 | network_exposure_audit | Network |
| 33 | ufw_default_policy | Network |
| 34 | ufw_ssh_restriction | Network |
| 35 | ufw_allowed_services | Network |
| 36 | ufw_rate_limit_ssh | Network |
| 37 | ufw_logging | Network |
| 38 | fail2ban_ssh_jail | Network |
| 39 | fail2ban_sudo_jail | Network |
| 40 | tcp_wrappers | Network |
| 41 | auditd_rules | Network |
| 42 | cron_at_restriction | Additional Hardening |
| 43 | securetty | Additional Hardening |
| 44 | log_file_perms | Additional Hardening |
| 45 | rsyslog_hardening | Additional Hardening |
| 46 | journald_hardening | Additional Hardening |
| 47 | service_account_hardening | Additional Hardening |
| 48 | debsums_verification | Additional Hardening |
| 49 | suid_strip_nonessential | Additional Hardening |
| 50 | systemd_service_hardening | Additional Hardening |
| 51 | capability_audit | Additional Hardening |
| 52 | hosts_equiv_removal | Additional Hardening |
| 53 | issue_content | Additional Hardening |
| 54 | dns_resolver_hardening | Additional Hardening |
| 55 | ntp_hardening | Additional Hardening |
| 56 | compiler_restriction | Additional Hardening |
| 57 | boot_perms | Additional Hardening |

---


## Rollback Philosophy

Every module's `README.md` documents how to reverse that specific control.
There is no single global rollback — hardening is granular, so undoing it
is granular too. Always test in a non-production environment first.

---

## License / Ownership

Internal project — Ubuntu 24.04 system hardening baseline.
Maintained incrementally, one module at a time.
