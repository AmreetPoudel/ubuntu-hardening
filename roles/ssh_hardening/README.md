# Role: ssh_hardening

## Description
Hardens OpenSSH server daemon config (disables root login, password auth, X11, strict ciphers).

## System Commands & Modifications
- Writes `/etc/ssh/sshd_config.d/99-hardening.conf`
- `systemctl restart sshd`

## Manual Rollback Steps
```bash
sudo rm -f /etc/ssh/sshd_config.d/99-hardening.conf
sudo systemctl restart sshd
```
