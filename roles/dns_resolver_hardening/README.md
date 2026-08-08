# Role: dns_resolver_hardening

## Description
Hardens systemd-resolved DNSSEC and DNS-over-TLS parameters.

## System Commands & Modifications
- Writes `/etc/systemd/resolved.conf.d/99-hardening.conf`
- `systemctl restart systemd-resolved`

## Manual Rollback Steps
```bash
sudo rm -f /etc/systemd/resolved.conf.d/99-hardening.conf
sudo systemctl restart systemd-resolved
```
