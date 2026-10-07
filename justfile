# Build with current host name
[default]
[group('main')]
build NAME="":
    sudo nixos-rebuild switch --flake .#{{ NAME }}

# Built with a specific specialization
[group('main')]
specialisation NAME:
    sudo nixos-rebuild switch --flake .# --specialisation {{ NAME }}

# List generations
[group('main')]
ls:
    nixos-rebuild list-generations

# Update flake inputs
[group('main')]
update:
    nix flake update

# Remove all generations except current
[group('main')]
gc:
    sudo nix-collect-garbage -d

# Show flake outputs
[group('main')]
show:
    nix flake show --all-systems

# Fix + Gate
[group('dev')]
qual: fix check

# Check flake outputs
[group('dev')]
check:
    nix flake check --all-systems --show-trace

# Format and lint
[group('dev')]
fix:
    nix fmt

# Generate hash for package
[group('dev')]
hash HASH:
    nix hash convert --to sri --hash-algo sha256 {{ HASH }}
