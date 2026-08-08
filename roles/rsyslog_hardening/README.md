# Role: rsyslog_hardening

## Description
Configures rsyslog file creation mode to 0640.

## System Commands & Modifications
- Writes `/etc/rsyslog.d/99-hardening.conf`
- `systemctl restart rsyslog`

## Manual Rollback Steps
```bash
sudo rm -f /etc/rsyslog.d/99-hardening.conf
sudo systemctl restart rsyslog
```
