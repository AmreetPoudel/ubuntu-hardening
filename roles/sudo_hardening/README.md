# Role: sudo_hardening

## Description
Enforces PTY allocation, sudo command logging to /var/log/sudo.log, and 5-minute timeout.

## System Commands & Modifications
- Writes `/etc/sudoers.d/99-sudo-hardening`

## Manual Rollback Steps
```bash
sudo rm -f /etc/sudoers.d/99-sudo-hardening
```
