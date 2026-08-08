# Role: ufw_allowed_services

## Description
Opens application and Docker/K8s specific ports in UFW.

## System Commands & Modifications
- `ufw allow <port>/<proto>`

## Manual Rollback Steps
```bash
sudo ufw delete allow <port>/<proto>
```
