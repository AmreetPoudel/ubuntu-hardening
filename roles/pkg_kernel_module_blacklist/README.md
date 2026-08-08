# Role: pkg_kernel_module_blacklist

## Description
Disables uncommon and vulnerable network transport kernel modules (dccp, sctp, rds, tipc).

## System Commands & Modifications
- Writes `/etc/modprobe.d/blacklist-hardening.conf`
- `modprobe -r dccp sctp rds tipc`

## Manual Rollback Steps
```bash
sudo rm -f /etc/modprobe.d/blacklist-hardening.conf
```
