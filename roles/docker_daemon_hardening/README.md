# Role: docker_daemon_hardening

## Description
Hardens Docker daemon (disables ICC, userland proxy, enforces no-new-privileges).

## System Commands & Modifications
- Writes `/etc/docker/daemon.json`
- `chmod 0660 /var/run/docker.sock`
- `systemctl restart docker`

## Manual Rollback Steps
```bash
sudo rm -f /etc/docker/daemon.json
sudo systemctl restart docker
```
