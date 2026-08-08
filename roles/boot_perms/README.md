# Role: boot_perms

## Description
Restricts permissions on /boot/grub/grub.cfg to 0600.

## System Commands & Modifications
- `chmod 0600 /boot/grub/grub.cfg`

## Manual Rollback Steps
```bash
sudo chmod 0644 /boot/grub/grub.cfg
```
