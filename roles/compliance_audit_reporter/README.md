# Role: compliance_audit_reporter

## Description
Evaluates CIS benchmark controls, calculates compliance %, renders HTML & JSON reports.

## System Commands & Modifications
- Evaluates SSH, Sysctl, PAM, Mounts, Permissions, Services
- Writes `reports/audit-report-*.html` and `.json`

## Manual Rollback Steps
```bash
# Audit reporter module. Generates reports only.
```
