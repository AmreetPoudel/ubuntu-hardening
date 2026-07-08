# Module 01 — pkg_remove_legacy

Removes old, insecure network service packages that aren't needed anymore.

## Packages removed

- inetutils-telnet
- inetutils-telnetd
- tftpd-hpa
- xinetd

## Manual steps (what we did before automating)

Check if installed:
```bash
dpkg -l | grep -E 'telnet|tftpd-hpa|xinetd'
```

Remove:
```bash
sudo apt remove --purge -y inetutils-telnet inetutils-telnetd tftpd-hpa xinetd
```

Confirm removed:
```bash
dpkg -l | grep -E 'telnet|tftpd-hpa|xinetd'
```
Should return nothing.

## Files in this module

- `vars/main.yml` — the package list
- `tasks/main.yml` — runs `apt` to remove whatever is in the list
