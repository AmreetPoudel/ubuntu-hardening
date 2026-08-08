# Role: log_file_perms

## Description
Enforces strict permissions (0640/0600) on /var/log files.

## System Commands & Modifications
- `chmod g-wx,o-rwx /var/log/*`

## Manual Rollback Steps
```bash
sudo chmod 0644 /var/log/syslog
```
