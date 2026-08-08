#!/usr/bin/env bash
# Generator script to scaffold a new hardening role in standard format.

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <role_name>"
    echo "Example: $0 firewall_nftables"
    exit 1
fi

ROLE_NAME="$1"
ROLE_DIR="roles/${ROLE_NAME}"

if [ -d "$ROLE_DIR" ]; then
    echo "Error: Directory ${ROLE_DIR} already exists."
    exit 1
fi

echo "Scaffolding new role: ${ROLE_NAME}..."

mkdir -p "${ROLE_DIR}/tasks"
mkdir -p "${ROLE_DIR}/vars"
mkdir -p "${ROLE_DIR}/handlers"
mkdir -p "${ROLE_DIR}/templates"

cat <<EOF > "${ROLE_DIR}/vars/main.yml"
---
# Module-scoped variables for ${ROLE_NAME}
${ROLE_NAME}_enabled: true
EOF

cat <<EOF > "${ROLE_DIR}/handlers/main.yml"
---
# Handlers for ${ROLE_NAME}
EOF

cat <<EOF > "${ROLE_DIR}/tasks/main.yml"
---
- name: Execute ${ROLE_NAME} controls
  block:

    - name: ${ROLE_NAME} baseline task
      ansible.builtin.debug:
        msg: "Executing module ${ROLE_NAME}"

  rescue:
    - name: Show failure message but keep going
      ansible.builtin.debug:
        msg: "WARNING: ${ROLE_NAME} failed on {{ inventory_hostname }}, check manually."
EOF

cat <<EOF > "${ROLE_DIR}/README.md"
# Role: ${ROLE_NAME}

## Description
Brief summary of what ${ROLE_NAME} hardens.

## Rollback
Steps or commands to reverse changes made by ${ROLE_NAME}.
EOF

chmod +x "${ROLE_DIR}"

echo "Successfully scaffolded role at ${ROLE_DIR}!"
