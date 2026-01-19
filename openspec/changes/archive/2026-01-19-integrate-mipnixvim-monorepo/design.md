# Design: Integrate mipnixvim into Monorepo

## Overview
This change moves mipnixvim from an external GitHub-based flake input to an integrated package within the mipnix monorepo, renamed to mipvim. The integration preserves the package's independence while enabling seamless local development.

## Architectural Decisions

### 1. Package Location and Naming
**Decision**: Place mipnixvim code in `packages/mipvim/` with the package renamed from mipnixvim to mipvim

**Rationale**:
- Follows common monorepo conventions for packaging separate components
- Separates packages from system configuration modules
- Shorter name (mipvim) is cleaner and easier to type while remaining clear
- Package maintains its own flake.nix and remains buildable independently
- Creates a clear location for future package additions (skull, myhotkeys, etc. could follow)

**Alternatives considered**:
- `packages/mipnixvim/` - Rejected: Name is longer than necessary
- `modules/packages/mipvim/` - Rejected: Mixing packages with NixOS/HM modules violates separation of concerns
- `pkgs/mipvim/` - Rejected: Too similar to nixpkgs convention, might cause confusion

### 2. Flake Integration Strategy
**Decision**: Use flake-parts `perSystem` to expose mipvim as a local package output

**Rationale**:
- Aligns with existing flake-parts architecture
- Provides clean `packages.${system}.mipvim` output
- Maintains compatibility with existing module references
- Allows the package to keep its own flake.nix for standalone builds

**Implementation approach**:
```nix
perSystem = { system, pkgs, ... }: {
  packages.mipvim = import ./packages/mipvim { inherit pkgs system; };
};
```

**Alternatives considered**:
- Direct inline definition - Rejected: Would lose mipnixvim's standalone buildability
- Git submodule - Rejected: Adds complexity without benefits, still requires external repo

### 3. Reference Update Strategy
**Decision**: Replace `inputs.mipnixvim` with `inputs.self` throughout codebase

**Rationale**:
- Minimal code changes: `mipnixvim.packages` → `self.packages`
- Leverages existing flake-parts special arguments mechanism
- Maintains backward compatibility with module structure

**Impact points**:
- `modules/users/pim/programs/neovim/default.nix`: Change package reference
- `modules/nix/helpers.nix`: Remove mipnixvim from specialArgs (if present)
- `flake.nix`: Remove input, add package output

### 4. Development Workflow
**Decision**: Support both monorepo and standalone development modes

**Rationale**:
- Monorepo mode: Direct edits in `packages/mipnixvim/`, instant rebuilds
- Standalone mode: mipnixvim retains its flake.nix for independent testing
- Maintains flexibility for potential future extraction if needed

**Git workflow**:
- Skull/smug configuration updated to point to `packages/mipvim/` instead of separate git clone
- Existing `~/mipnixvim` working copies remain valid but become redundant

### 5. Version Management
**Decision**: mipvim versions follow monorepo versioning

**Rationale**:
- Simplifies dependency management
- Enables atomic updates across system and neovim configuration
- Removes flake.lock update friction

**External GitHub repository**:
- Decision deferred to deployment phase
- Options: Archive, mark read-only, continue mirroring, or delete
- No immediate action required for this change

## Migration Path

### Phase 1: Structure Setup
1. Create `packages/` directory
2. Merge mipnixvim repository into `packages/mipvim/` preserving git history with contributor filtering
3. Verify mipvim builds independently: `nix build ./packages/mipvim`

#### Git History Integration Strategy
**Decision**: Use git subtree to preserve complete history while filtering out bot contributors

**Approach**:
1. Clone mipnixvim to temporary location
2. Filter out bot contributors using git filter-repo:
   - renovate-bot
   - github-actions[bot]
   - renovate[bot]
3. Use git subtree add to merge filtered history into `packages/mipvim/`

**Rationale**:
- Preserves meaningful commit history and authorship
- Removes automated bot commits that don't add value to monorepo history
- Maintains clean git blame and git log output
- Allows future git bisect operations across full history

**Tools required**: git-filter-repo (available in nixpkgs)

### Phase 2: Flake Integration
1. Add package output in perSystem
2. Remove external input from inputs section
3. Update flake.lock: `nix flake update`

### Phase 3: Reference Updates
1. Update neovim module to reference self.packages
2. Update helpers.nix if needed
3. Update skull/smug configurations

### Phase 4: Validation
1. Test build: `nix flake check`
2. Test neovim installation: `./RUNME.sh up_home`
3. Verify neovim launches and functions correctly

## Risks and Mitigations

### Risk: Build breakage
**Mitigation**: Keep external input temporarily during testing, switch atomically

### Risk: Lost git history
**Mitigation**: Preserve complete git history using git subtree with contributor filtering; all human commits retained

### Risk: Git history pollution from bots
**Mitigation**: Filter out bot contributors (renovate-bot, github-actions[bot], renovate[bot]) before merging to keep history clean

### Risk: Circular dependencies
**Mitigation**: mipvim's flake.nix should not depend on mipnix; keep it standalone-compatible

### Risk: Large repository size
**Mitigation**: Acceptable - mipvim is primarily Lua/Nix text files, minimal size impact

## Future Considerations

### Potential follow-on integrations
Similar pattern could be applied to:
- skull (git working copy manager)
- myhotkeys (GTK hotkeys manager)
- mip.rs (markdown viewer)
- dirtygit (git status tool)

### Multi-package monorepo structure
If multiple packages are integrated, consider:
- Shared CI/CD workflows
- Package-specific versioning metadata
- Cross-package dependency management
