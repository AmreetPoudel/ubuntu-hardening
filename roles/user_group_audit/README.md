# Role: user_group_audit

## Description
Audits user account database files for integrity and syntax errors.

## System Commands & Modifications
- `pwck -r`
- `grpck -r`

## Manual Rollback Steps
```bash
# Audit-only module. No state changes made.
```
