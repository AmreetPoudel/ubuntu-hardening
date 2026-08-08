# Role: hosts_equiv_removal

## Description
Deletes legacy rsh/rlogin trust files (/etc/hosts.equiv and .rhosts).

## System Commands & Modifications
- `rm -f /etc/hosts.equiv`
- `find /home /root -name .rhosts -delete`

## Manual Rollback Steps
```bash
# Recreate /etc/hosts.equiv if required by legacy systems.
```
