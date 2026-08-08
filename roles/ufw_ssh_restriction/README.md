# Role: ufw_ssh_restriction

## Description
Allows SSH access in UFW with optional IP subnet restriction.

## System Commands & Modifications
- `ufw allow proto tcp from <allowed_ip> to any port 22`

## Manual Rollback Steps
```bash
sudo ufw delete allow 22/tcp
```
