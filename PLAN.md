## Plan: Computer Setup Automation with Ansible (Revised)

Create an Ansible-based automation system to set up macOS and Fedora machines with auto-installing prerequisites (Homebrew, Ansible), managing applications via Homebrew casks, symlinking dotfiles, handling 1Password CLI secrets, and configuring macOS preferences.

### Steps

1. **Create bootstrap script** (`bootstrap.sh`) that:
   - Detects OS (macOS vs Fedora)
   - On macOS: Installs Xcode Command Line Tools if missing (required for Homebrew)
   - Installs Homebrew (macOS) or ensures DNF is updated (Fedora)
   - Installs Ansible via pip3 (macOS) or dnf (Fedora)
   - Launches the main Ansible playbook with error handling

2. **Build project structure** with:
   - `ansible.cfg` - Ansible configuration with settings for localhost execution
   - `inventory/local` - Localhost inventory file
   - `playbooks/` - main.yml, macos.yml, fedora.yml with tags support
   - `roles/` - Modular roles for each function
   - `vars/` - Package lists per OS (macos.yml, fedora.yml, common.yml)
   - `dotfiles/` - Actual config files following XDG Base Directory spec:
     - `dotfiles/config/fish/` → `~/.config/fish/`
     - `dotfiles/config/starship.toml` → `~/.config/starship.toml`
     - `dotfiles/gitconfig` → `~/.gitconfig`
   - `backup/` - Directory for backing up existing dotfiles before symlinking

3. **Create prerequisite roles**:
   - `roles/xcode-clt/` - Install Xcode Command Line Tools on macOS
   - `roles/homebrew-setup/` - Ensure Homebrew is properly configured

4. **Create Homebrew roles**:
   - `roles/homebrew-packages/` - Install CLI tools (fish, starship, wget, node, python, podman, podman-compose, micro, gh, git-lfs)
   - `roles/homebrew-casks/` - Install GUI apps (1password, 1password-cli, slack, visual-studio-code, zed, github, ungoogled-chromium, arc, zen-browser, obsidian, devpod, signal, windows-app, tailscale, protonvpn)
   - Use `community.general.homebrew` and `homebrew_cask` modules with `state: present`

5. **Create Fedora package roles**:
   - `roles/dnf-packages/` - Install CLI tools via DNF with Fedora package names
   - `roles/flatpak-apps/` - Install GUI apps via Flatpak with mapping from Homebrew cask names

6. **Implement dotfiles role** (`roles/dotfiles/`):
   - Backup existing dotfiles to `~/dotfiles-backup-TIMESTAMP/` if they exist
   - Create symlinks using Ansible's `file` module with `state: link`
   - Handle XDG directories: ensure `~/.config/`, `~/.local/share/` exist
   - Symlink structure: `~/.<file>` → `{{ playbook_dir }}/dotfiles/<file>`
   - Include git configuration (username, email) via template

7. **Build shell configuration role** (`roles/shell-setup/`):
   - Configure Fish to initialize Starship: add `starship init fish | source` to config.fish
   - Add 1Password CLI integration examples with `op read` commands
   - Set Fish as default shell via `chsh -s $(which fish)` with user confirmation
   - Install Fisher (Fish plugin manager) if needed

8. **Create platform-specific setup roles**:
   - `roles/macos-defaults/` - Set macOS preferences via `community.general.osx_defaults`:
     - Finder: Always show list view, show hidden files, show path bar
     - Dock: Auto-hide, position, icon size
     - Keyboard/Trackpad: Key repeat rate, tracking speed
     - Screenshots: Change default location
   - `roles/podman-macos/` - Initialize Podman machine on macOS (`podman machine init && podman machine start`)

9. **Add 1Password integration**:
   - Document in README that user must manually sign in to 1Password app first
   - Include example Fish config with `op read` for secrets (e.g., `VOLVO_CARS_PAT`)
   - Verify `op` CLI is authenticated before dotfiles that use it are applied

10. **Create entry points**:
    - `Makefile` with targets: `setup`, `macos`, `fedora`, `dotfiles-only`, `apps-only`
    - Comprehensive README.md with prerequisites, usage, and troubleshooting

### Implementation Details

**Role Execution Order** (with dependencies resolved):
1. Bootstrap script (Xcode CLT, Homebrew/DNF, Ansible installation)
2. Homebrew/DNF packages (CLI tools including fish, starship, git, node, python, podman)
3. Homebrew Casks/Flatpak (GUI apps including 1Password, 1Password CLI, VS Code, etc.)
4. Dotfiles symlinks (after tools are installed so configs reference existing binaries)
5. Shell setup (Fish configuration with Starship, set as default shell)
6. Platform-specific setup (macOS defaults, Podman machine init)
7. Verification (check all tools installed, configs in place)

**Tag Strategy** for selective execution:
- `bootstrap` - Prerequisites only
- `packages` - CLI tools
- `apps` - GUI applications
- `dotfiles` - Configuration files
- `shell` - Shell setup and config
- `macos` - macOS-specific tasks
- `fedora` - Fedora-specific tasks
- `verify` - Verification checks

**Error Handling**:
- Bootstrap script exits with clear error messages if prerequisite installation fails
- Ansible playbook uses `ignore_errors: false` for critical tasks
- Each role includes verification tasks to confirm success
- Backup dotfiles before symlinking so rollback is possible

**Idempotency Verification**:
- All Ansible modules used (homebrew, file, osx_defaults) are idempotent by design
- Script can be run multiple times safely
- Use `creates` parameter for shell commands that aren't naturally idempotent
- Check for existing symlinks before creating new ones

**Version Management Consideration**:
- Node and Python installed via Homebrew/DNF (system versions)
- For project-specific versions, document using `asdf-vm` or similar in README
- Keep base system simple; users can add version managers later if needed

### Key Decisions

**Dotfiles organization**: Symlink approach - keeps dotfiles in repo for git tracking and instant sync. Follow XDG Base Directory spec (`~/.config/`, `~/.local/share/`) for modern tool compatibility. Backup existing files to timestamped directory before symlinking.

**Prerequisites**: Auto-install via bootstrap script:
- macOS: Xcode CLT → Homebrew → Python/pip → Ansible
- Fedora: DNF update → Python/pip → Ansible

**Package management**:
- macOS: Homebrew for CLI tools, Homebrew Cask for GUI apps
- Fedora: DNF for CLI tools, Flatpak for GUI apps
- Map cask names to Fedora equivalents (e.g., `visual-studio-code` → `code` from VS Code repo)

**Shell setup**: Automatically set Fish as default shell with user confirmation. Configure Fish to initialize Starship on startup. Include Fisher plugin manager for extensibility.

**Secrets management**: Store secrets in 1Password, access via `op` CLI in dotfiles. User must manually sign in to 1Password app before running playbook. Include verification task to check `op account list` succeeds.

**macOS preferences**: Use `osx_defaults` module for system settings:
- Finder: List view, show hidden files, show path bar, show extensions
- Dock: Auto-hide, position, size
- Keyboard/Trackpad: Faster key repeat, tracking speed
- Screenshots: Custom save location

**Podman on macOS**: Separate role to initialize Podman machine after installation (required for Podman to work on macOS).

**Git configuration**: Include basic git setup (username, email) via Ansible template in dotfiles role. User-specific values in separate vars file or prompted during first run.

**Version managers**: Use system Node/Python from Homebrew/DNF for simplicity. Document `asdf-vm`, `nvm`, `pyenv` as optional additions in README for users needing multiple versions.

**Testing approach**: Test in VM (macOS VM, Fedora VM) before running on main machine. Use `--check` flag for dry runs. Tag-based execution allows testing individual components.
