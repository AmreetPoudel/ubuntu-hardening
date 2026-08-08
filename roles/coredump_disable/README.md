# Role: coredump_disable

## Description
Disables system process core dumps via security limits and systemd-coredump.

## System Commands & Modifications
- Writes `/etc/security/limits.d/10-disable-coredumps.conf`
- Configures `Storage=none` in `/etc/systemd/coredump.conf`

## Manual Rollback Steps
```bash
sudo rm -f /etc/security/limits.d/10-disable-coredumps.conf
sudo sed -i 's/Storage=none/Storage=external/' /etc/systemd/coredump.conf
```
