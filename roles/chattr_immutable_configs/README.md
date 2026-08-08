# Role: chattr_immutable_configs

## Description
Applies filesystem immutable attribute (chattr +i) on security configuration files.

## System Commands & Modifications
- `chattr +i /etc/pam.d/common-password /etc/security/pwquality.conf`

## Manual Rollback Steps
```bash
sudo chattr -i /etc/pam.d/common-password /etc/security/pwquality.conf
```
