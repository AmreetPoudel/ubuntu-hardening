# Role: umask_hardening

## Description
Enforces system umask 027 in login.defs and profile environment scripts.

## System Commands & Modifications
- Writes `/etc/profile.d/99-umask.sh`
- Edits `UMASK 027` in `/etc/login.defs`

## Manual Rollback Steps
```bash
sudo rm -f /etc/profile.d/99-umask.sh
sudo sed -i 's/^UMASK.*/UMASK 022/' /etc/login.defs
```
