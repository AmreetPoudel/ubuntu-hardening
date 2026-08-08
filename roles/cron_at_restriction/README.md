# Role: cron_at_restriction

## Description
Restricts cron and at job scheduling strictly to root user.

## System Commands & Modifications
- Writes `/etc/cron.allow` and `/etc/at.allow`
- Removes `/etc/cron.deny` and `/etc/at.deny`

## Manual Rollback Steps
```bash
sudo rm -f /etc/cron.allow /etc/at.allow
```
