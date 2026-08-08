# Role: suid_sgid_audit

## Description
Audits and reports all SUID and SGID executables across local mounts.

## System Commands & Modifications
- `find / -xdev \( -perm -4000 -o -perm -2000 \) -type f`

## Manual Rollback Steps
```bash
# Audit-only module. No state changes made.
```
