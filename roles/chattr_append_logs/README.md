# Role: chattr_append_logs

## Description
Applies append-only attribute (chattr +a) on system security logs.

## System Commands & Modifications
- `chattr +a /var/log/auth.log /var/log/syslog`

## Manual Rollback Steps
```bash
sudo chattr -a /var/log/auth.log /var/log/syslog
```
