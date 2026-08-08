# Linux Hardening Operations & Execution Guide

This guide explains how to deploy, customize, and execute the Ansible Ubuntu 24.04 Hardening Framework across different production environments and workloads.

---

## 1. Prerequisites

Before running the playbook:
- **Control Node**: Linux/macOS with Python 3.10+ and Ansible 2.16+.
- **Target OS**: Ubuntu 24.04 LTS servers with root or sudo user access.
- **SSH Access**: Configured SSH keys or passwords.

Install required Ansible collections:
```bash
ansible-galaxy collection install ansible.posix community.general
```

---

## 2. Setting Up Inventory & Vault Secrets

Copy the example inventory file to create your environment inventory:
```bash
cp inventory.example.ini inventory.ini
```

Edit `inventory.ini` to assign target hosts into appropriate workload groups:
```ini
[standalone]
srv-app-01 ansible_host=10.0.0.10 ansible_user=admin

[docker_nodes]
srv-docker-01 ansible_host=10.0.0.20 ansible_user=admin

[k8s_nodes]
k8s-node-01 ansible_host=10.0.0.30 ansible_user=admin
k8s-node-02 ansible_host=10.0.0.31 ansible_user=admin
```

### Encrypting Inventory with Ansible Vault
To securely store passwords or sensitive variables in `inventory.ini`:
```bash
# Encrypt inventory file
ansible-vault encrypt inventory.ini

# Edit encrypted inventory file
ansible-vault edit inventory.ini
```

When running playbooks against encrypted inventories, supply `--ask-vault-pass` or `--vault-password-file`.

---

## 3. Running the Playbook

### A. Full System Hardening
Run all 57 hardening controls across all targets in `inventory.ini`:
```bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

### B. Dry-Run / Audit Mode (Check Only)
Preview what changes would be made without altering system state:
```bash
ansible-playbook -i inventory.ini site.yml --check --diff
```

### C. Running Specific Workload Profiles
Target only Docker nodes or Kubernetes nodes:
```bash
# Target Docker nodes only
ansible-playbook -i inventory.ini site.yml -l docker_nodes

# Target Kubernetes nodes only
ansible-playbook -i inventory.ini site.yml -l k8s_nodes
```

### D. Running Specific Module Controls (By Tag)
Run only SSH hardening:
```bash
ansible-playbook -i inventory.ini site.yml --tags ssh_hardening
```

Run only Sysctl kernel tunables:
```bash
ansible-playbook -i inventory.ini site.yml --tags sysctl_hardening
```

Run UFW firewall rules:
```bash
ansible-playbook -i inventory.ini site.yml --tags ufw
```

### E. Running Category Modules
Run all Authentication controls:
```bash
ansible-playbook -i inventory.ini site.yml --tags auth
```

Run Network & Firewall controls:
```bash
ansible-playbook -i inventory.ini site.yml --tags network
```

Run Filesystem controls:
```bash
ansible-playbook -i inventory.ini site.yml --tags filesystem
```

---

## 4. Scaffolding New Hardening Roles

To create a new custom hardening role using the project template:
```bash
./scripts/new_module.sh 58_custom_security_rule
```
This generates the role directory with `tasks/main.yml`, `vars/main.yml`, `handlers/main.yml`, `templates/`, and `README.md`.

---

## 5. Reviewing Reports & Audits

Execution logs and task status summaries are written to:
```
/var/log/ansible-hardening/run-summary.log
```
Check this log after every run to inspect any modules flagged as `FAILED` or `SKIPPED`.
