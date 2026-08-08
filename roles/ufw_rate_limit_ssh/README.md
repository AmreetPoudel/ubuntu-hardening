# Role: ufw_rate_limit_ssh

## Description
Applies UFW connection rate limiting on SSH port.

## System Commands & Modifications
- `ufw limit 22/tcp`

## Manual Rollback Steps
```bash
sudo ufw delete limit 22/tcp
```
