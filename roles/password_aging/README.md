# Role: password_aging

## Description
Enforces password expiration rules in /etc/login.defs (PASS_MAX_DAYS 90).

## System Commands & Modifications
- Edits `PASS_MAX_DAYS`, `PASS_MIN_DAYS`, `PASS_WARN_AGE` in `/etc/login.defs`

## Manual Rollback Steps
```bash
sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 99999/' /etc/login.defs
```
