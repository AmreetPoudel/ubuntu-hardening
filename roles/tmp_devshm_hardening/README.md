# Role: tmp_devshm_hardening

## Description
Mounts /tmp and /dev/shm with nodev, nosuid, noexec flags to block binary execution.

## System Commands & Modifications
- Updates `/etc/fstab` for `/tmp` and `/dev/shm`
- `mount -o remount /tmp`
- `mount -o remount /dev/shm`

## Manual Rollback Steps
```bash
sudo mount -o remount,exec /tmp
sudo mount -o remount,exec /dev/shm
```
