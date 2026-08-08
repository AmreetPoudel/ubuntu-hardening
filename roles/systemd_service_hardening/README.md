# Role: systemd_service_hardening

## Description
Enforces DefaultPrivateTmp=yes isolation in systemd system.conf.

## System Commands & Modifications
- Configures `DefaultPrivateTmp=yes` in `/etc/systemd/system.conf`

## Manual Rollback Steps
```bash
sudo sed -i 's/DefaultPrivateTmp=yes/DefaultPrivateTmp=no/' /etc/systemd/system.conf
```
