# Linux Hardening Operations & Execution Guide

This guide explains how to deploy, customize, and execute the Ansible Ubuntu 24.04 Hardening Framework across different production environments, server roles, and technology stacks.

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

[db_nodes]
srv-db-01 ansible_host=10.0.0.40 ansible_user=admin

[web_nodes]
srv-web-01 ansible_host=10.0.0.50 ansible_user=admin
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

## 3. Running Non-Disruptive Security Audits

To audit system compliance score without modifying any system configuration:
```bash
ansible-playbook -i inventory.ini playbooks/audit_compliance.yml
```
This generates interactive **HTML** and **JSON** compliance reports in:
`reports/audit-report-<hostname>-<timestamp>.html` and `.json`.

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
ansible-playbook -i inventory.ini playbooks/base_os.yml
```

### C. Docker Engine Hardening
Hardens Docker daemon settings (`/etc/docker/daemon.json`, socket permissions, live-restore, journald logs):
```bash
ansible-playbook -i inventory.ini playbooks/docker_host.yml
```

### D. Kubernetes Node Hardening
Hardens Kubernetes Kubelet configuration, disables swap, and secures node configuration:
```bash
ansible-playbook -i inventory.ini playbooks/k8s_node.yml
```

### E. Database Server Hardening
Hardens PostgreSQL database instances (SSL enforcement, SCRAM-SHA-256, listen interfaces, data dir perms):
```bash
ansible-playbook -i inventory.ini playbooks/database_server.yml
```

### F. Web Server Hardening
Hardens Nginx web servers (`server_tokens off`, HSTS, X-Frame-Options, TLSv1.2/1.3):
```bash
ansible-playbook -i inventory.ini playbooks/web_server.yml
```

---

## 5. Running Specific Module Controls (By Tag)

Run only SSH hardening:
```bash
ansible-playbook -i inventory.ini site.yml --tags ssh_hardening
```

Run Docker daemon security:
```bash
ansible-playbook -i inventory.ini site.yml --tags docker_daemon
```

Run PostgreSQL security:
```bash
ansible-playbook -i inventory.ini site.yml --tags postgres
```

Run Nginx security:
```bash
ansible-playbook -i inventory.ini site.yml --tags nginx
```

---

## 6. Dry-Run / Audit Mode (Check Only)

Preview what changes would be made without altering system state:
```bash
ansible-playbook -i inventory.ini site.yml --check --diff
```

---

## 7. Scaffolding New Hardening Roles

To create a new custom hardening role using the project template:
```bash
./scripts/new_module.sh 58_redis_hardening
```
