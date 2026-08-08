# Role: postgres_hardening

## Description
Enforces PostgreSQL SSL/TLS, SCRAM-SHA-256, connection logging, and 0700 data dir perms.

## System Commands & Modifications
- Writes `/etc/postgresql/99-hardening.conf`
- `chmod 0700 /var/lib/postgresql`
- `systemctl reload postgresql`

## Manual Rollback Steps
```bash
sudo rm -f /etc/postgresql/99-hardening.conf
sudo systemctl reload postgresql
```
