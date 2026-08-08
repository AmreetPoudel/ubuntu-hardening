# Role: aide_baseline

## Description
Initializes AIDE integrity monitoring baseline database.

## System Commands & Modifications
- `aideinit`
- `cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz`

## Manual Rollback Steps
```bash
sudo rm -f /var/lib/aide/aide.db.gz /var/lib/aide/aide.db.new.gz
```
