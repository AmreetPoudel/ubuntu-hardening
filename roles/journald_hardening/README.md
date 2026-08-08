# Role: journald_hardening

## Description
Configures persistent, compressed systemd-journald log storage.

## System Commands & Modifications
- Writes `/etc/systemd/journald.conf.d/99-hardening.conf`
- `systemctl restart systemd-journald`

## Manual Rollback Steps
```bash
sudo rm -f /etc/systemd/journald.conf.d/99-hardening.conf
sudo systemctl restart systemd-journald
```
