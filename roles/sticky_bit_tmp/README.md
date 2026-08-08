# Role: sticky_bit_tmp

## Description
Enforces sticky bit (chmod 1777) on /tmp and /var/tmp directories.

## System Commands & Modifications
- `chmod 1777 /tmp /var/tmp`

## Manual Rollback Steps
```bash
sudo chmod 0777 /tmp /var/tmp
```
