# Linux Hardening Operations & Execution Guide

This guide explains how to deploy, customize, and execute the Ansible Ubuntu 24.04 Hardening Framework across different production environments, server roles, and technology stacks.

---

## 1. Prerequisites

Before running the playbook:
- **Control Node**: Linux/macOS with Python 3.10+ and Ansible 2.16+.
- **Target OS**: Ubuntu 24.04 LTS servers with root or sudo user access.
- **Ansible Collections**: `ansible.posix`, `community.general`.

Install required Ansible collections:
```bash
ansible-galaxy collection install ansible.posix community.general
```

---

## 2. Setting Up Inventory & Vault Password Security Architecture

To prevent lateral movement if the Ansible control node is ever compromised, **do not use passwordless SSH keys**. Instead, store target SSH usernames, SSH passwords, and sudo become passwords directly in `inventory.ini` and encrypt the entire file using **Ansible Vault**.

Copy the example inventory template:
```bash
cp inventory.example.ini inventory.ini
```

Edit `inventory.ini` with target IP addresses, usernames, and passwords:
```ini
[standalone]
srv-app-01 ansible_host=10.0.0.10 ansible_user=admin ansible_ssh_pass="MySecretPass123!" ansible_become_password="MySecretPass123!"

[docker_nodes]
srv-docker-01 ansible_host=10.0.0.20 ansible_user=admin ansible_ssh_pass="MySecretPass123!" ansible_become_password="MySecretPass123!"

[k8s_nodes]
k8s-node-01 ansible_host=10.0.0.30 ansible_user=admin ansible_ssh_pass="MySecretPass123!" ansible_become_password="MySecretPass123!"

[db_nodes]
srv-db-01 ansible_host=10.0.0.40 ansible_user=admin ansible_ssh_pass="MySecretPass123!" ansible_become_password="MySecretPass123!"

[web_nodes]
srv-web-01 ansible_host=10.0.0.50 ansible_user=admin ansible_ssh_pass="MySecretPass123!" ansible_become_password="MySecretPass123!"
```

### Encrypting Inventory with Ansible Vault
```bash
# Encrypt inventory file
ansible-vault encrypt inventory.ini

# Edit encrypted inventory file in the future
ansible-vault edit inventory.ini
```

When running any playbooks against encrypted inventories, always supply `--ask-vault-pass` or `--vault-password-file`:
```bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

---

## 3. Running Non-Disruptive Security Audits

To scan target servers, calculate compliance scores, and generate **HTML** and **JSON** reports without altering any system settings:

```bash
ansible-playbook -i inventory.ini playbooks/audit_compliance.yml --ask-vault-pass
```

Reports are saved to `reports/`:
- `reports/audit-report-<hostname>-<timestamp>.html`
- `reports/audit-report-<hostname>-<timestamp>.json`

---

## 4. Running Specialized Workload Playbooks

### A. Full Fleet Hardening & Audit Report
Runs Base OS, all technology playbooks, and generates post-hardening audit reports:
```bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

### B. Base OS Hardening Only
Applies baseline Ubuntu 24.04 OS security (SSH, PAM, sysctl, filesystem perms, auditd, UFW baseline):
```bash
ansible-playbook -i inventory.ini playbooks/base_os.yml --ask-vault-pass
```

### C. Docker Engine Hardening
Hardens Docker daemon settings (`/etc/docker/daemon.json`, socket permissions, live-restore, journald logs):
```bash
ansible-playbook -i inventory.ini playbooks/docker_host.yml --ask-vault-pass
```

### D. Kubernetes Node Hardening
Hardens Kubernetes Kubelet configuration, disables swap, and secures node configuration:
```bash
ansible-playbook -i inventory.ini playbooks/k8s_node.yml --ask-vault-pass
```

### E. Database Server Hardening
Hardens PostgreSQL database instances (SSL enforcement, SCRAM-SHA-256, listen interfaces, data dir perms):
```bash
ansible-playbook -i inventory.ini playbooks/database_server.yml --ask-vault-pass
```

### F. Web Server Hardening
Hardens Nginx web servers (`server_tokens off`, HSTS, X-Frame-Options, TLSv1.2/1.3):
```bash
ansible-playbook -i inventory.ini playbooks/web_server.yml --ask-vault-pass
```

---

## 5. Running Specific Module Controls (By Tag)

Run only SSH hardening:
```bash
ansible-playbook -i inventory.ini site.yml --tags ssh_hardening --ask-vault-pass
```

Run Docker daemon security:
```bash
ansible-playbook -i inventory.ini site.yml --tags docker_daemon --ask-vault-pass
```

Run PostgreSQL security:
```bash
ansible-playbook -i inventory.ini site.yml --tags postgres --ask-vault-pass
```

Run Nginx security:
```bash
ansible-playbook -i inventory.ini site.yml --tags nginx --ask-vault-pass
```

---

## 6. Dry-Run / Audit Mode (Check Only)

Preview what changes would be made without altering system state:
```bash
ansible-playbook -i inventory.ini site.yml --check --diff --ask-vault-pass
```

---

## 7. Scaffolding New Hardening Roles

To create a new custom hardening role using the project template:
```bash
./scripts/new_module.sh 62_redis_hardening
```
