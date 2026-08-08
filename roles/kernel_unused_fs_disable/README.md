# Role: kernel_unused_fs_disable

## Description
Disables mounting of legacy and unused filesystems (cramfs, freevxfs, jffs2, hfs, hfsplus, udf).

## System Commands & Modifications
- Writes `/etc/modprobe.d/fs-hardening.conf`

## Manual Rollback Steps
```bash
sudo rm -f /etc/modprobe.d/fs-hardening.conf
```
