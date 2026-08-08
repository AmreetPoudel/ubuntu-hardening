# Role: pkg_install_hardening_tools

## Description
Installs essential security, firewall, auditing, and integrity monitoring packages (`auditd`, `ufw`, `fail2ban`, `aide`, `debsums`, `apparmor-utils`).

## Tasks Executed
- `apt install` for `hardening_tools_packages`.

## Rollback
```bash
sudo apt remove --purge auditd debsums fail2ban aide ufw libpam-pwquality apparmor-utils acct
```
