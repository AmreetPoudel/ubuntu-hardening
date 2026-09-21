#!/usr/bin/env bash
# Scaffold a new hardening role that follows this project's conventions.
set -euo pipefail

if [ "$#" -ne 1 ] || ! [[ "$1" =~ ^[a-z][a-z0-9_]*$ ]]; then
    echo "Usage: $0 <role_name>   (lowercase letters, digits and underscores)" >&2
    echo "Example: $0 redis_hardening" >&2
    exit 1
fi

cd "$(dirname "$0")/.."
role="roles/$1"
[ -e "$role" ] && { echo "Error: $role already exists." >&2; exit 1; }

mkdir -p "$role/tasks"
cat > "$role/tasks/main.yml" <<TASKS
---
# Conventions:
#  - Settings belong in group_vars/all.yml (one policy file), not in the role.
#  - No block/rescue that swallows errors: a failure must fail the host. Use rescue only to roll back and then fail.
#  - Validate before replacing a config that can lock people out (validate:, or test then restore).
#  - Be idempotent and safe in --check mode (read-only commands need check_mode: false).
#  - Use fully-qualified module names (ansible.builtin.*).
- name: Describe what $1 enforces
  ansible.builtin.debug:
    msg: "Replace me"
TASKS

echo "Created $role. Next: add it to a playbook in playbooks/, its settings to group_vars/all.yml,"
echo "and a check to roles/compliance_audit/vars/main.yml."
