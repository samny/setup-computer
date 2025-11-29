# Computer Setup Automation

Automated setup for macOS and Fedora machines using Ansible. This project installs applications, manages dotfiles, and configures system preferences to quickly set up a new development environment.

## Features

- **Cross-platform**: Works on macOS and Fedora Linux
- **Idempotent**: Safe to run multiple times
- **Modular**: Use tags to run specific parts
- **Automated prerequisites**: Installs Homebrew/DNF and Ansible automatically
- **Dotfiles management**: Symlink-based with XDG compliance
- **1Password integration**: Examples for CLI-based secrets management

## Prerequisites

### Manual Steps (Before Running)

1. **macOS only**: Accept Xcode license if prompted
2. **1Password**: Sign in to 1Password app and authenticate CLI
   ```bash
   op signin
   ```

### Auto-installed by Bootstrap

- **macOS**: Xcode Command Line Tools, Homebrew, Ansible
- **Fedora**: Ansible, Python packages

## Quick Start

```bash
# Clone this repository
git clone https://github.com/samny/setup-computer.git
cd setup-computer

# Run the complete setup
./bootstrap.sh

# Or use Make targets
make setup
```

## Usage

### Complete Setup

```bash
./bootstrap.sh
```

This will:

1. Detect your OS
2. Install prerequisites (Homebrew, Ansible)
3. Install all packages and applications
4. Set up dotfiles
5. Configure system preferences (macOS)

### Selective Installation

Use Make targets for specific tasks:

```bash
make packages-only   # Install CLI tools only
make apps-only       # Install GUI applications only
make dotfiles-only   # Set up dotfiles only
make macos          # Run macOS-specific tasks only
make fedora         # Run Fedora-specific tasks only
```

### Dry Run

Check what would change without making changes:

```bash
make check
```

### Using Ansible Directly

```bash
# Run with specific tags
ansible-playbook -i inventory/local playbooks/main.yml --tags dotfiles

# Available tags: bootstrap, packages, apps, dotfiles, shell, macos, fedora, verify
```

## Installed Tools

### CLI Tools

- **Shell**: fish, starship
- **Development**: node, python, gh, git-lfs
- **Utilities**: wget, micro, podman, podman-compose

### GUI Applications (macOS)

- **Productivity**: 1password, slack, obsidian
- **Development**: visual-studio-code, zed, github, devpod
- **Browsers**: ungoogled-chromium, arc, zen-browser
- **Utilities**: signal, windows-app, tailscale, protonvpn
- **Fonts**: FiraCode Nerd Font (with ligatures and powerline symbols)

### GUI Applications (Fedora)

Similar applications installed via Flatpak. See `vars/fedora.yml` for the complete list.

## Project Structure

```
setup-computer/
├── bootstrap.sh              # Entry point script
├── Makefile                  # Convenient make targets
├── ansible.cfg               # Ansible configuration
├── inventory/
│   └── local                 # Localhost inventory
├── playbooks/
│   ├── main.yml             # Main playbook
│   ├── darwin.yml           # macOS-specific
│   └── redhat.yml           # Fedora-specific
├── roles/                    # Ansible roles
│   ├── homebrew-setup/      # Install Homebrew packages and casks
│   ├── dnf-packages/        # Install DNF packages
│   ├── flatpak-apps/        # Install Flatpak apps
│   ├── dotfiles/            # Manage dotfiles
│   ├── shell-setup/         # Configure Fish shell
│   ├── macos-defaults/      # macOS system preferences
│   └── podman-macos/        # Podman setup for macOS
├── vars/
│   ├── macos.yml            # macOS package lists
│   ├── fedora.yml           # Fedora package lists
│   └── common.yml           # Common variables
└── dotfiles/
    └── config/
        ├── fish/            # Fish shell config
        └── starship.toml    # Starship prompt config
```

## Customization

### Modify Package Lists

Edit the variable files to add or remove packages:

- `vars/macos.yml` - Homebrew packages and casks
- `vars/fedora.yml` - DNF packages and Flatpak apps
- `vars/common.yml` - Git config and other common settings

### Add Custom Dotfiles

1. Add your dotfiles to `dotfiles/config/`
2. Update `roles/dotfiles/tasks/main.yml` to symlink them

### Modify macOS Preferences

Edit `roles/macos-defaults/tasks/main.yml` to change system settings.

### Enable Optional Settings

The project includes optional configuration files with additional settings that are commented out by default:

- **macOS**: `roles/macos-defaults/tasks/optional.yml` - Hidden files in Finder, keyboard repeat rates, trackpad settings
- **Fedora**: `roles/fedora-gnome-settings/tasks/optional.yml` - Keyboard shortcuts, touchpad/mouse settings, Night Light, window management, Firefox scroll speed

To use optional settings:

1. Edit the optional.yml file for your platform
2. Uncomment the tasks you want to enable
3. Add the optional file to your playbook:

```yaml
# In playbooks/darwin.yml or playbooks/redhat.yml
- name: Run optional macOS/GNOME settings
  ansible.builtin.include_tasks: roles/macos-defaults/tasks/optional.yml # or fedora-gnome-settings
  tags: [macos-optional] # or [gnome-optional]
```

4. Run with the optional tag:

```bash
ansible-playbook -i inventory/local playbooks/main.yml --tags macos-optional --ask-become-pass
# or
ansible-playbook -i inventory/local playbooks/main.yml --tags gnome-optional --ask-become-pass
```

## 1Password Integration

The Fish config includes commented examples for loading secrets from 1Password:

```fish
# In ~/.config/fish/config.fish
if not set -q VOLVO_CARS_PAT
    set -Ux VOLVO_CARS_PAT (op read "op://Private/GitHub/personal_access_token_packages")
end
```

Uncomment and customize as needed after signing in to 1Password CLI.

## Manual Configuration

### Terminal Fonts

FiraCode Nerd Font is installed automatically. To configure it in your terminal:

**Terminal.app:**

1. Terminal → Settings → Profiles
2. Select a profile (e.g., "Basic")
3. Click "Font" → Change to "FiraCodeNerdFont-Regular" or "FiraCodeNerdFontMono-Regular"
4. Recommended size: 13pt
5. Set as default profile

**iTerm2:**

1. iTerm2 → Settings → Profiles → Text
2. Click "Font" dropdown
3. Select "FiraCodeNerdFont-Regular" or "FiraCodeNerdFontMono-Regular"
4. Recommended size: 13pt
5. Enable "Use ligatures" for programming symbols

## Troubleshooting

### Homebrew Installation Fails

If Homebrew installation fails on Apple Silicon Macs, manually install it first:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Ansible Not Found After Bootstrap

Add Python user bin to your PATH:

```bash
export PATH="$HOME/Library/Python/3.11/bin:$PATH"
```

### 1Password CLI Not Authenticated

Sign in to 1Password CLI before running the playbook:

```bash
op signin
```

### Permission Denied Errors

Some tasks require sudo privileges. Ensure your user has sudo access.

### Dotfiles Backup

Existing dotfiles are automatically backed up to `~/dotfiles-backup-TIMESTAMP/` before symlinking.

## Testing

Test in a VM before running on your main machine:

```bash
# Dry run (check mode)
make check

# Run specific parts
make dotfiles-only
```

## Version Managers

This setup installs system versions of Node and Python. For project-specific versions, consider:

- **asdf-vm**: Universal version manager
- **nvm**: Node.js version manager
- **pyenv**: Python version manager

## Contributing

Feel free to fork and customize for your own needs!

## License

MIT

## Acknowledgments

- Inspired by [geerlingguy/mac-dev-playbook](https://github.com/geerlingguy/mac-dev-playbook)
- [Ansible Documentation](https://docs.ansible.com/)
- [Homebrew](https://brew.sh/)
