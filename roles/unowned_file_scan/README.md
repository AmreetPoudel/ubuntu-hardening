# Role: unowned_file_scan

## Description
Scans for orphan files lacking assigned UID/GID owners and assigns root ownership.

## System Commands & Modifications
- `find / -xdev \( -nouser -o -nogroup \) -exec chown root:root {} +`

## Manual Rollback Steps
```bash
# Dependent on original owner.
```
