# Role: sysctl_hardening

## Description
Applies Linux kernel network stack protection, ASLR, and memory security tunables.

## System Commands & Modifications
- Writes `/etc/sysctl.d/99-sysctl-hardening.conf`
- `sysctl --system`

## Manual Rollback Steps
```bash
sudo rm -f /etc/sysctl.d/99-sysctl-hardening.conf
sudo sysctl --system
```
