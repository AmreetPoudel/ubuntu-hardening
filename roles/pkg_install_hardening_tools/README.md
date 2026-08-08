# Role: pkg_install_hardening_tools

## Description
Installs security auditing, firewall, integrity monitoring, and PAM packages.

## System Commands & Modifications
- `apt install auditd debsums fail2ban aide ufw libpam-pwquality apparmor-utils acct`

## Manual Rollback Steps
```bash
sudo apt remove --purge -y auditd debsums fail2ban aide ufw libpam-pwquality apparmor-utils acct
```
