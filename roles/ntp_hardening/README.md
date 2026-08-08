# Role: ntp_hardening

## Description
Installs and enables Chrony time synchronization daemon.

## System Commands & Modifications
- `apt install chrony`
- `systemctl enable --now chrony`

## Manual Rollback Steps
```bash
sudo systemctl disable --now chrony
sudo apt remove --purge chrony
```
