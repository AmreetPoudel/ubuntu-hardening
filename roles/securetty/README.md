# Role: securetty

## Description
Restricts direct root console logins to tty1 via /etc/securetty.

## System Commands & Modifications
- Writes `/etc/securetty`

## Manual Rollback Steps
```bash
sudo rm -f /etc/securetty
```
