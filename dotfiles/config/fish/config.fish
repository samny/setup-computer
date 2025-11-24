# Fish shell configuration

# Initialize Starship prompt
if command -v starship &> /dev/null
    starship init fish | source
end

# 1Password CLI integration examples
# Uncomment and customize as needed

# Load GitHub token from 1Password
# if not set -q VOLVO_CARS_PAT
#     set -Ux VOLVO_CARS_PAT (op read "op://Private/GitHub/personal_access_token_packages")
# end

# Add other environment variables or configurations below
