.PHONY: deps lint syntax test

deps:            ## install required Ansible collections
	ansible-galaxy collection install -r requirements.yml

lint:            ## yamllint + ansible-lint (production profile)
	yamllint .
	ansible-lint

syntax:          ## syntax-check every playbook against the example inventory
	ansible-playbook -i inventory.example.ini site.yml --syntax-check
	ansible-playbook -i inventory.example.ini playbooks/security_scan.yml --syntax-check

test:            ## disposable Ubuntu 24.04 container: apply, idempotence, --check, workloads, audit
	./tests/run.sh
