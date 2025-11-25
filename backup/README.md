# Backup Directory

This directory is automatically created by the Ansible playbook to store backups of your existing dotfiles before they are replaced with symlinks.

Backup directories are named with timestamps: `~/dotfiles-backup-TIMESTAMP/`

The repository's `backup/` directory itself is not used during execution - it exists only for organizational purposes.
