# Role: ssh_hostkey_hardening

## Description
Restricts SSH host key algorithms to Ed25519 and RSA 4096.

## System Commands & Modifications
- Configures HostKey directives in `/etc/ssh/sshd_config.d/99-hardening.conf`

## Manual Rollback Steps
```bash
sudo sed -i '/HostKey/d' /etc/ssh/sshd_config.d/99-hardening.conf
sudo systemctl restart sshd
```
