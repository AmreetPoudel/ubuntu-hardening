# Module 03 — unattended_upgrades

Installs and configures automatic security updates so patches apply without manual intervention.

## What it does

- Installs `unattended-upgrades` and `apt-listchanges`
- Configures `/etc/apt/apt.conf.d/20auto-upgrades` to enable daily package list updates and automatic security upgrades

## Manual steps (what we did before automating)

Check if installed:
```bash
dpkg -l | grep unattended-upgrades
```

Install:
```bash
sudo apt install -y unattended-upgrades apt-listchanges
```

Check config:
```bash
cat /etc/apt/apt.conf.d/20auto-upgrades
cat /etc/apt/apt.conf.d/50unattended-upgrades
```

Test without waiting for the timer:
```bash
sudo unattended-upgrade --dry-run --debug
```

Check the timer is active:
```bash
systemctl status unattended-upgrades --no-pager
systemctl list-timers | grep apt
```

## Files in this module

- `vars/main.yml` — package list
- `templates/20auto-upgrades.j2` — the config file content
- `tasks/main.yml` — installs packages, deploys config, notifies restart on change
- `handlers/main.yml` — restarts unattended-upgrades, only if config changed

## Run it

```bash
ansible-playbook -i inventory.ini site.yml --tags unattended_upgrades
```

Run twice. Second run should show `ok` on both tasks, no `changed`, handler should not fire.

## Rollback

```bash
sudo systemctl stop unattended-upgrades
sudo systemctl disable unattended-upgrades
```
Or edit `/etc/apt/apt.conf.d/20auto-upgrades` and set both lines back to `"0"`.