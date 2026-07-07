# Project Structure Reference

## Top-Level Files

- **ansible.cfg** — Project-scoped Ansible config. `[defaults]`: inventory path, roles_path, stdout_callback=yaml, error_on_undefined_vars=True. `[privilege_escalation]`: become=True. `[ssh_connection]`: pipelining=True, control_path.

- **site.yml** — Master playbook. Canary play (serial:1, any_errors_fatal:true) + fleet play (serial:25%, max_fail_percentage:0). Lists roles in dependency order with tags.

- **inventory.ini** — Real hosts/IPs. Gitignored.

- **inventory.example.ini** — Sanitized template, committed to git.

- **.gitignore** — Excludes reports/*.json, *.retry, inventory.ini, __pycache__.

- **README.md** — Project philosophy, module index, usage, tier explanation.


Rule: only cross-module values go here. Single-module tunables stay in that role's own vars/main.yml.


## reports/

Runtime output. JSON-lines format (one JSON object per line, not a JSON array) — append-safe across concurrent hosts. .gitkeep tracks the empty dir; actual report files are gitignored.

## roles/NN_module_name/

- **vars/main.yml** — control-specific values (ciphers, password depth, IP allowlists) + `<module>_enabled: true` flag.

- **tasks/main.yml** — block/rescue/always structure:
  - `block:` — idempotent logic (check state first, mutate only if different)
  - `rescue:` — Tier 2: record FAILED, continue. Tier 1: restore backup, then explicit `fail:` (required — rescue alone does NOT halt the play by default)
  - `always:` — append JSON report line regardless of outcome

- **handlers/main.yml** — service restart/reload, only fires on `changed`, only if `notify:`'d from tasks. Never restart unconditionally in tasks/main.yml — breaks idempotency.

- **templates/** — Jinja2 configs for modules that manage a full file (vs. lineinfile edits on a file you don't fully own).


## The One Rule

Project-wide vs. module-scoped is the only axis that matters. If more than one module needs a value, it goes in group_vars/all.yml. If it's specific to one control, it stays in that role's own vars/main.yml.