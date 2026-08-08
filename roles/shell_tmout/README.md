# Role: shell_tmout

## Description
Enforces 15-minute auto-logout on idle interactive shell sessions.

## System Commands & Modifications
- Writes `/etc/profile.d/99-timeout.sh` setting `readonly TMOUT=900`

## Manual Rollback Steps
```bash
sudo rm -f /etc/profile.d/99-timeout.sh
```
