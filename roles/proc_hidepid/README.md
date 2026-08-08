# Role: proc_hidepid

## Description
Mounts /proc with hidepid=2 to restrict process visibility across users.

## System Commands & Modifications
- Updates `/etc/fstab` for `/proc` mount options
- `mount -o remount /proc`

## Manual Rollback Steps
```bash
sudo mount -o remount,hidepid=0 /proc
```
