# Role: tcp_wrappers

## Description
Configures TCP wrappers (/etc/hosts.allow and /etc/hosts.deny).

## System Commands & Modifications
- Writes `ALL: ALL` to `/etc/hosts.deny`
- Writes SSH/localhost rules to `/etc/hosts.allow`

## Manual Rollback Steps
```bash
sudo truncate -s 0 /etc/hosts.deny /etc/hosts.allow
```
