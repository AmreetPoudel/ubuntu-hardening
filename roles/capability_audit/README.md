# Role: capability_audit

## Description
Audits Linux extended capabilities assigned to system binaries.

## System Commands & Modifications
- `getcap -r /usr /bin /sbin`

## Manual Rollback Steps
```bash
# Audit-only module. No state changes made.
```
