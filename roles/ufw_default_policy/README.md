# Role: ufw_default_policy

## Description
Enforces UFW Default Deny incoming firewall policy.

## System Commands & Modifications
- `ufw default deny incoming`
- `ufw default allow outgoing`
- `ufw enable`

## Manual Rollback Steps
```bash
sudo ufw default allow incoming
sudo ufw disable
```
