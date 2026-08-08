# Role: sensitive_file_perms

## Description
Sets strict ownership and 0600/0644 permissions on /etc/shadow, passwd, group, crontab.

## System Commands & Modifications
- `chmod 0600 /etc/shadow /etc/gshadow /etc/crontab`
- `chmod 0644 /etc/passwd /etc/group`

## Manual Rollback Steps
```bash
sudo chmod 0644 /etc/shadow /etc/gshadow
```
