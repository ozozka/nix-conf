# Project Commands
# Usage: just <recipe>
# Run `just --list` to see all available recipes.

# Deployment and daily usage commands

# Build with current host name
[default]
[group('main')]
build NAME="":
    sudo nixos-rebuild switch --flake .#{{ NAME }}

# Built with a specific specialization
[group('main')]
specialization NAME:
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

# Run fastfetch
[group('main')]
info:
    nix run .#info

# Show flake outputs
[group('main')]
show:
    nix flake show --all-systems

# Quality and checks

# Fix + Gate
[group('qual')]
qual: fix ci

# Full check
[group('qual')]
ci: check

# Check format, lint, and flake outputs.
[group('qual')]
check:
    nix flake check --all-systems --show-trace

# Format and lint
[group('qual')]
fix: fmt

# Format and lint
[group('qual')]
fmt:
    nix fmt

# Packages and development

# Generate ssh key
[group('dev')]
key:
    ssh-keygen

# Generate hash for package
[group('dev')]
hash HASH:
    nix hash convert --to sri --hash-algo sha256 {{ HASH }}
