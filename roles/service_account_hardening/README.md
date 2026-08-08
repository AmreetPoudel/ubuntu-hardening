# Role: service_account_hardening

## Description
Sets /usr/sbin/nologin shell for non-root system daemon accounts (UID < 1000).

## System Commands & Modifications
- `usermod -s /usr/sbin/nologin <daemon-user>`

## Manual Rollback Steps
```bash
sudo usermod -s /bin/bash <user>
```
