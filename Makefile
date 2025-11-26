.PHONY: setup macos fedora dotfiles-only apps-only packages-only help check

help:
	@echo "Computer Setup Automation"
	@echo ""
	@echo "Available targets:"
	@echo "  setup         - Run complete setup (bootstrap + all roles)"
	@echo "  macos         - Run macOS-specific setup only"
	@echo "  fedora        - Run Fedora-specific setup only"
	@echo "  packages-only - Install CLI packages only"
	@echo "  apps-only     - Install GUI applications only"
	@echo "  dotfiles-only - Setup dotfiles only"
	@echo "  check         - Dry run to see what would change"
	@echo "  help          - Show this help message"

setup:
	@echo "Running complete setup..."
	./bootstrap.sh --ask-become-pass

macos:
	@echo "Running macOS setup..."
	ansible-playbook -i inventory/local playbooks/main.yml --tags macos --ask-become-pass

fedora:
	@echo "Running Fedora setup..."
	ansible-playbook -i inventory/local playbooks/main.yml --tags fedora --ask-become-pass

packages-only:
	@echo "Installing packages only..."
	ansible-playbook -i inventory/local playbooks/main.yml --tags packages --ask-become-pass

apps-only:
	@echo "Installing applications only..."
	ansible-playbook -i inventory/local playbooks/main.yml --tags apps --ask-become-pass

dotfiles-only:
	@echo "Setting up dotfiles only..."
	ansible-playbook -i inventory/local playbooks/main.yml --tags dotfiles --ask-become-pass

check:
	@echo "Running in check mode (dry run)..."
	ansible-playbook -i inventory/local playbooks/main.yml --check
