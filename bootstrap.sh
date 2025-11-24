#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/fedora-release ]]; then
        echo "fedora"
    else
        echo "unknown"
    fi
}

# Install Xcode Command Line Tools (macOS only)
install_xcode_clt() {
    if xcode-select -p &>/dev/null; then
        log_info "Xcode Command Line Tools already installed"
    else
        log_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        log_warn "Please complete the Xcode CLT installation and run this script again"
        exit 0
    fi
}

# Install Homebrew (macOS only)
install_homebrew() {
    if command -v brew &>/dev/null; then
        log_info "Homebrew already installed"
    else
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
}

# Install Ansible on macOS
install_ansible_macos() {
    if command -v ansible &>/dev/null; then
        log_info "Ansible already installed"
    else
        log_info "Installing Ansible via pip3..."
        if ! command -v pip3 &>/dev/null; then
            log_info "Installing Python3..."
            brew install python3
        fi
        pip3 install --user ansible
        
        # Add Python user bin to PATH
        export PATH="$HOME/Library/Python/3.11/bin:$PATH"
    fi
}

# Install Ansible on Fedora
install_ansible_fedora() {
    if command -v ansible &>/dev/null; then
        log_info "Ansible already installed"
    else
        log_info "Updating DNF..."
        sudo dnf update -y
        
        log_info "Installing Ansible..."
        sudo dnf install -y ansible python3-pip
    fi
}

# Main execution
main() {
    log_info "Starting bootstrap process..."
    
    OS=$(detect_os)
    log_info "Detected OS: $OS"
    
    case $OS in
        macos)
            install_xcode_clt
            install_homebrew
            install_ansible_macos
            ;;
        fedora)
            install_ansible_fedora
            ;;
        *)
            log_error "Unsupported OS: $OSTYPE"
            exit 1
            ;;
    esac
    
    # Verify Ansible installation
    if command -v ansible &>/dev/null; then
        log_info "Ansible installed successfully: $(ansible --version | head -n 1)"
    else
        log_error "Ansible installation failed"
        exit 1
    fi
    
    # Install Ansible Galaxy collections
    log_info "Installing required Ansible Galaxy collections..."
    ansible-galaxy collection install community.general
    
    log_info "Bootstrap complete! Running Ansible playbook..."
    
    # Run the main playbook
    cd "$(dirname "$0")"
    ansible-playbook -i inventory/local playbooks/main.yml "$@"
}

main "$@"
