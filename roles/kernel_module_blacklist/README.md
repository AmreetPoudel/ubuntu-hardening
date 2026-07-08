# Module 04 — kernel_module_blacklist

Disables loading of uncommon network protocol kernel modules that are rarely used and have a history of vulnerabilities (CVE track record in dccp/sctp/rds/tipc specifically).

## Modules blacklisted

- dccp
- sctp
- rds
- tipc

## Manual steps (what we did before automating)

Check if currently loaded:
```bash
lsmod | grep -E 'dccp|sctp|rds|tipc'
```

Create the blacklist config:
```bash
sudo tee /etc/modprobe.d/blacklist-hardening.conf <<EOF
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true
blacklist dccp
blacklist sctp
blacklist rds
blacklist tipc
EOF
```

Note: `install <module> /bin/true` is what actually blocks loading even if something explicitly requests it (e.g. `modprobe dccp` by name). Plain `blacklist` only stops it from auto-loading — it doesn't stop an explicit `modprobe` call. Using both is the standard CIS pattern.

Unload if currently loaded:
```bash
sudo modprobe -r dccp sctp rds tipc
```
If this errors with "module in use," something depends on it — check `lsof` / running services before forcing anything further.

Verify:
```bash
lsmod | grep -E 'dccp|sctp|rds|tipc'
```
Should return nothing.

Try to reload on purpose to confirm the block works:
```bash
sudo modprobe dccp
echo $?
```
Should fail / exit non-zero, or load nothing.

## Files in this module

- `vars/main.yml` — list of modules to blacklist
- `templates/blacklist-hardening.conf.j2` — the modprobe config content
- `tasks/main.yml` — deploys the config, unloads modules if currently loaded

## Run it

```bash
ansible-playbook -i inventory.ini site.yml --tags kernel_module_blacklist
```

Run twice. Second run should show `ok`, config task not `changed`.

## Rollback

```bash
sudo rm /etc/modprobe.d/blacklist-hardening.conf
sudo modprobe dccp sctp rds tipc   # only if you actually need them back
```