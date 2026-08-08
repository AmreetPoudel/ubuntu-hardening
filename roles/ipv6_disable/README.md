# Role: ipv6_disable

## Description
Hardens IPv6 router advertisements or disables IPv6 interface entirely.

## System Commands & Modifications
- Writes `/etc/sysctl.d/99-ipv6-hardening.conf`
- `sysctl --system`

## Manual Rollback Steps
```bash
sudo rm -f /etc/sysctl.d/99-ipv6-hardening.conf
sudo sysctl --system
```
