# Role: network_exposure_audit

## Description
Audits and displays open listening TCP and UDP sockets.

## System Commands & Modifications
- `ss -tulpn`

## Manual Rollback Steps
```bash
# Audit-only module. No state changes made.
```
