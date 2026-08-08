# Role: auditd_rules

## Description
Deploys CIS auditd rules monitoring identity changes and sudo executions.

## System Commands & Modifications
- Writes `/etc/audit/rules.d/audit.rules`
- `systemctl restart auditd`

## Manual Rollback Steps
```bash
sudo rm -f /etc/audit/rules.d/audit.rules
sudo systemctl restart auditd
```
