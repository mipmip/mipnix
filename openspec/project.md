# Project Context

## Purpose
Personal NixOS configuration mono-repository ("mipnix") for managing multiple
machines and dotfiles across diverse hardware (laptops, Raspberry Pi servers,
PinePhone, Android). Provides declarative, reproducible system configurations
with integrated Home Manager for user environment management.

## Tech Stack
- **NixOS (latest stable)** (primary) with flakes enabled
- **Home Manager** (following latest stable nixos) for dotfiles and user environment
- **Dendritc Design with the Flake Parts Framework** - for modular flake organization
- **agenix** for encrypted secrets management
- **Nebula VPN** for mesh networking between machines
- **Hyprland** as primary desktop environment.
- **Neovim** (heavily customized via mipnixvim)
- **Terminal emulators**: 
    - ghostty (primary), 
    - kitty, 
    - alacritty, 
- **Shell**: zsh, fish (primary)
- **tmux**: 
    - tmux heavily custimized
    - smug for declaritive session configuration
    - skull (git working copy manager)
- **Programming languages**: Rust, Go, Python, Ruby, Node.js, Crystal, COBOL, C
- **Infrastructure tools**: Docker, Terraform, AWS CLI
- **Custom tools**:
  - mip.rs (markdown viewer in Rust)
  - myhotkeys (GTK hotkeys manager in Crystal)
  - bmc, race (technative IAC tools)
  - dirtygit (git status tool)

## Managed Hosts

### Active Machines
- **harry-pi**: Raspberry Pi 4 server (aarch64) - Nextcloud, Matrix, Seafile
- **hurry-pi**: Raspberry Pi server - Home Assistant
- **lego2-laptop**: Laptop (x86_64)
- **passieflora-laptop**: Laptop (x86_64)
- **pesto-pinephone**: PinePhone mobile device (aarch64, mobile-nixos)
- **nix-on-droid-fairphone**: Fairphone with nix-on-droid (24.05)

### Resource-Constrained Hosts
Hosts **harry** and **hurry** require special build flags due to limited resources:
- `--max-jobs 1 -j 1 --cores 1`

## Project Conventions

### Code Style
- **Language**: Nix with flakes
- **Formatting**: Not yet enforced (nixfmt-classic available but commented out)
- **File naming**: kebab-case for .nix files
- **Module naming**: Descriptive paths like `programs/desktop/apps/browsers.nix`

### Architecture Patterns

#### Flake Structure
Uses **flake-parts** for modular organization:
```
flake.nix (root)
├── inputs (dependencies from GitHub)
├── modules/ (auto-imported via import-tree)
│   ├── hosts/ (per-machine configurations)
│   ├── programs/ (application groups)
│   ├── services/ (system services)
│   ├── system/ (core system config)
│   ├── users/ (user definitions)
│   ├── nix/ (nix-specific: overlays, helpers, age)
│   └── home-manager/ (HM integration)
├── home/ (Home Manager user configs)
│   ├── pim/ (primary user)
│   ├── annemarie/ (secondary user)
│   └── _roles/ (shared role configs: desktop, secondbrain)
└── secrets/ (agenix encrypted secrets)
```

#### Module Organization
- **System modules**: Located in `modules/` and organized by function
- **Home Manager modules**: Located in `home/<user>/_hm-modules/`
- **Role-based configuration**: Use `roles.desktop` and `roles.secondbrain` for feature grouping (deprecated)
- **Host-specific**: `modules/hosts/<hostname>/configuration.nix` imports relevant modules

#### Custom Library Functions
- `self.lib.makeNixos`: Creates NixOS configurations
- `self.lib.makeHomeConf`: Creates Home Manager configurations

### Configuration Management

#### Secrets (agenix)
1. Register in `secrets/secrets.nix` with authorized users/systems
2. Encrypt: `agenix -i ~/.ssh/id_ed25519 -e <file>.age`
3. Add to system: Import in `modules/system/trusted/agenix.nix`
4. Access: `config.age.secrets.<name>.path`

#### Desktop Configuration
- **Primary DE**: GNOME with extensive customization via dconf
- **Custom extensions**: Some packaged from GitHub (ahead of nixpkgs)
- **Hotkeys**: Managed via myhotkeys (Crystal application)
- **Terminal aesthetic**: Custom St patches, special writing theme with high line-height

#### Ricing Mode
Use **hm-ricing-mode** for safe config testing:
- `hmrice rice` - activate test mode
- `hmrice unrice` - revert changes
- Blocks `up_home` command when ricing is active

### Git Workflow

#### Branch Strategy
- **Main branch**: `main`
- **Direct commits**: Work directly on main branch

#### Commit Process
Use `./RUNME.sh git_sync_machine "<message>"`:
1. Creates commit with message
2. Tags with format: `<hostname>-<YYYY-MM-DD>`
3. Removes existing same-day tags automatically (local & remote)
4. Pushes tags to remote

**Requirements**:
- Commit message required (fails if missing)
- Tag conflicts auto-resolved by deletion

#### Deployment Commands
- **Home Manager**: `./RUNME.sh up_home`
  - Checks for ricing mode
  - Checks for untracked files (blocks if found)
  - Applies with `--impure` flag
  - Auto-commits with "auto run after home-manager switch"

- **NixOS rebuild**: `./RUNME.sh up_machine`
  - Checks for untracked files (blocks if found)
  - Applies resource limits for harry/hurry hosts
  - Only syncs git if rebuild succeeds
  - Auto-commits with "auto run after nixos-rebuild switch"

#### Untracked Files Policy
Both `up_home` and `up_machine` **FAIL** if untracked files exist (uncommitted changes are OK).

### Utility Script (RUNME.sh)
Custom bash framework for common tasks:
- `nixclean` / `nixcleanyesterday` - Garbage collection
- `nixoptimise` - Store optimization
- `git_sync_machine "<msg>"` - Commit and tag workflow
- `up_home` - Update Home Manager with auto-commit
- `up_machine` - Update NixOS with auto-commit
- `new_nebula_node` - Interactive Nebula certificate creation
- `setup_aws_key` - Bootstrap AWS credentials from secrets
- `copy_privkey_to_remote <user@host>` - Securely copy SSH key

## Domain Context

### Networking
- **Nebula mesh VPN**: Connects all machines in private overlay network
- **Certificates**: Per-machine, managed via agenix
- **IP scheme**: 192.168.100.0/24 (CIDR notation)

### Desktop Workflow
- **Writing environment**: High line-height, dedicated font, pure white background, grayscale theme in Vim
- **Window management**: GNOME with useless-gaps, focus-changer, dash-to-panel extensions
- **Terminal multiplexing**: tmux with custom configs (shortcut 'a' for desktop, 'b' for servers)

### Development Setup
- **Neovim**: Primary editor with extensive Lua config (telescope, gitsigns, LSP, etc.)
- **Git tools**: dirtygit for status, custom aliases
- **AI assistance**: aider, avante plugin (disabled by default)

### Second Brain 
- **Second brain**: Markdown-based with skull for managing working copies
- **Linny**: NeoVim Plugin which serves as second brain
- **Hugo**: Custom Hugo site which serves as indexer for Linny

### AWS Integration
- **Profiles**: Multiple accounts managed via JSON
- **MFA**: Automated via aws-mfa tool
- **Secrets**: Credentials/config encrypted with age
- **Updates**: `technativeawsupdate` pulls latest account info from S3

## Important Constraints

### Build Limitations
- **Raspberry Pi hosts** (harry, hurry): Limited CPU/RAM requires `--max-jobs 1 -j 1 --cores 1`
- **PinePhone**: Special mobile-nixos build process, requires SD card flashing

### Security Constraints
- **SSH keys**: ed25519 keys used for agenix decryption
- **Secrets**: Never commit unencrypted to git
- **Remote access**: Private keys only copied to trusted hosts

### Version Pinning
- **Primary**: nixos-25.11
- **Compatibility**: nixos-24.11 for user 'annemarie' (GNOME 47)
- **PinePhone**: Pinned to older nixpkgs (22.05 era)
- **Android**: nix-on-droid 24.05

## External Dependencies

### GitHub-based Inputs
- **nixos/nixpkgs**: Main package source (multiple channels)
- **nix-community/home-manager**: User environment management
- **ryantm/agenix**: Secrets encryption
- **mipmip/***: Personal packages (mipnixvim, skull, myhotkeys, etc.)
- **wearetechnative/***: Work-related tools (bmc, race)
- **nixos/nixos-hardware**: Hardware-specific configs
- **mobile-nixos**: PinePhone support

### Services Hosted
- **harry-pi**: Nextcloud, Seafile, Matrix homeserver, Cloudflared tunnels
- **hurry-pi**: Home Assistant
- **Various hosts**: PostgreSQL, Ollama, LiteLLM, Open WebUI

### External Services
- **AWS**: Multiple accounts, S3 for shared configs
- **GitHub**: Git remote, package sources, CI/CD (implied)
- **Cloudflare**: DNS and tunnel management (for harry-pi services)
