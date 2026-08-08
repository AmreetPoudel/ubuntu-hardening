# Role: world_writable_scan

## Description
Finds world-writable files (perm -0002) and strips write bit for others.

## System Commands & Modifications
- `find / -xdev -type f -perm -0002 -exec chmod o-w {} +`

## Manual Rollback Steps
```bash
# Dependent on individual file requirements.
```
