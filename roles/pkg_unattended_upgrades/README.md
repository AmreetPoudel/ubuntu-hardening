# Role: pkg_unattended_upgrades

## Description
Installs and configures automatic security update patching via unattended-upgrades.

## System Commands & Modifications
- `apt install unattended-upgrades apt-listchanges`
- Writes `/etc/apt/apt.conf.d/auto-upgrades`
- `systemctl restart unattended-upgrades`

## Manual Rollback Steps
```bash
sudo rm -f /etc/apt/apt.conf.d/auto-upgrades
sudo systemctl stop unattended-upgrades
```
