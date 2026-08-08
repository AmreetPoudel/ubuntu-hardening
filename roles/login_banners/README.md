# Role: login_banners

## Description
Deploys legal security warning banners to /etc/issue, /etc/issue.net, and /etc/motd.

## System Commands & Modifications
- Writes `/etc/issue`, `/etc/issue.net`, and `/etc/motd`

## Manual Rollback Steps
```bash
sudo truncate -s 0 /etc/issue /etc/issue.net /etc/motd
```
