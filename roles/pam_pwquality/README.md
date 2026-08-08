# Role: pam_pwquality

## Description
Enforces password complexity rules (min length 14, 4 character classes).

## System Commands & Modifications
- Writes `/etc/security/pwquality.conf`

## Manual Rollback Steps
```bash
sudo rm -f /etc/security/pwquality.conf
```
