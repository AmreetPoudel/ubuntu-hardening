# Role: pam_faillock

## Description
Locks user accounts for 15 minutes after 5 consecutive failed login attempts.

## System Commands & Modifications
- Writes `/etc/security/faillock.conf`

## Manual Rollback Steps
```bash
sudo rm -f /etc/security/faillock.conf
sudo faillock --reset
```
