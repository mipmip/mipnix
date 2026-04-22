make_command "new_host" "Create a new NixOS host configuration"
new_host(){
  # Check required tools
  if ! command -v gum &> /dev/null; then
    echo "Error: gum is not installed"
    exit 1
  fi

  # Interactive prompts
  HOST_NAME=$(gum input --placeholder "Enter hostname (e.g., birdie)")
  if [[ -z "$HOST_NAME" ]]; then
    echo "Error: Hostname is required"
    exit 1
  fi

  HOST_TYPE=$(gum input --placeholder "Enter type suffix (e.g., laptop, pi, server)")
  if [[ -z "$HOST_TYPE" ]]; then
    echo "Error: Type suffix is required"
    exit 1
  fi

  HOST_ARCH=$(gum choose "x86_64-linux" "aarch64-linux")
  if [[ -z "$HOST_ARCH" ]]; then
    echo "Error: Architecture is required"
    exit 1
  fi

  HOST_DIR="modules/HOSTS/${HOST_NAME}-${HOST_TYPE}"

  # Check for duplicate
  if [[ -d "$HOST_DIR" ]]; then
    echo "Error: Host directory '$HOST_DIR' already exists"
    exit 1
  fi

  # Check NixOS configuration files exist
  HW_SOURCE="/etc/nixos/hardware-configuration.nix"
  CFG_SOURCE="/etc/nixos/configuration.nix"
  if [[ ! -f "$HW_SOURCE" ]]; then
    echo "Error: $HW_SOURCE not found. This must be run on a NixOS machine."
    exit 1
  fi
  if [[ ! -f "$CFG_SOURCE" ]]; then
    echo "Error: $CFG_SOURCE not found. This must be run on a NixOS machine."
    exit 1
  fi

  # Auto-discover available roles from modules/ROLES/
  AVAILABLE_ROLES=()
  for rolefile in modules/ROLES/*.nix; do
    ROLE_NAME=$(grep -o 'flake\.modules\.nixos\.role-[a-z0-9-]*' "$rolefile" 2>/dev/null | head -1 | sed 's/flake\.modules\.nixos\.//')
    if [[ -n "$ROLE_NAME" ]]; then
      AVAILABLE_ROLES+=("$ROLE_NAME")
    fi
  done

  # Interactive role selection
  SELECTED_ROLES=()
  if [[ ${#AVAILABLE_ROLES[@]} -gt 0 ]]; then
    echo "Select roles for this host (space to toggle, enter to confirm):"
    ROLE_SELECTION=$(printf '%s\n' "${AVAILABLE_ROLES[@]}" | gum choose --no-limit)
    if [[ -n "$ROLE_SELECTION" ]]; then
      while IFS= read -r role; do
        SELECTED_ROLES+=("$role")
      done <<< "$ROLE_SELECTION"
    fi
  fi

  # Build roles display string
  if [[ ${#SELECTED_ROLES[@]} -gt 0 ]]; then
    ROLES_DISPLAY=$(printf ', %s' "${SELECTED_ROLES[@]}")
    ROLES_DISPLAY="${ROLES_DISPLAY:2}"
  else
    ROLES_DISPLAY="none"
  fi

  # Confirmation
  gum style --border normal --padding "1 2" --border-foreground 33 \
    "Creating new host:" \
    "  Hostname: $HOST_NAME" \
    "  Type: $HOST_TYPE" \
    "  Architecture: $HOST_ARCH" \
    "  Roles: $ROLES_DISPLAY" \
    "  Directory: $HOST_DIR" \
    "" \
    "Files to create:" \
    "  • $HOST_DIR/configuration.nix" \
    "  • $HOST_DIR/hardware.nix" \
    "  • $HOST_DIR/networking.nix"

  if ! gum confirm "Proceed with host creation?"; then
    echo "Cancelled"
    exit 0
  fi

  mkdir -p "$HOST_DIR"

  # --- hardware.nix ---
  # Extract body from hardware-configuration.nix by stripping the function
  # signature and outer braces, then wrap in flake module pattern
  HW_BODY=$(sed -n '/^{$/,/^}$/{/^{$/d;/^}$/d;p}' "$HW_SOURCE")
  if [[ -z "$HW_BODY" ]]; then
    # Fallback: signature and opening brace on same line (e.g., "{ config, ... }: {")
    HW_BODY=$(sed '1,/^{/d;$d' "$HW_SOURCE")
  fi
  # Remove imports block (contains modulesPath reference to installer scan)
  HW_BODY=$(echo "$HW_BODY" | sed '/^\s*imports\s*=/,/\];/d')

  cat > "$HOST_DIR/hardware.nix" <<HWEOF
{
lib,
inputs,
...
}:
{
  flake.modules.nixos.${HOST_NAME} = { config, pkgs, lib, ... }: {
    # Auto-imported from $HW_SOURCE
    # Review and adjust as needed

${HW_BODY}
  };
}
HWEOF

  # --- configuration.nix ---
  # Extract body from /etc/nixos/configuration.nix, stripping:
  # - function signature and outer braces
  # - imports block (references ./hardware-configuration.nix)
  # - comment-only lines
  CFG_BODY=$(sed -n '/^{$/,/^}$/{/^{$/d;/^}$/d;p}' "$CFG_SOURCE")
  if [[ -z "$CFG_BODY" ]]; then
    CFG_BODY=$(sed '1,/^{/d;$d' "$CFG_SOURCE")
  fi
  # Remove imports block, comment-only lines, and networking.hostName (handled in networking.nix)
  CFG_BODY=$(echo "$CFG_BODY" | sed '/^\s*imports\s*=/,/\];/d' | sed '/^\s*#.*$/d' | sed '/^\s*networking\.hostName\s*=/d' | sed '/^\s*system\.stateVersion\s*=/d' | sed '/^\s*$/N;/^\s*\n\s*$/d')

  # Build roles imports for configuration.nix
  ROLES_IMPORTS=""
  for role in "${SELECTED_ROLES[@]}"; do
    ROLES_IMPORTS="${ROLES_IMPORTS}      ${role}
"
  done

  cat > "$HOST_DIR/configuration.nix" <<CFGEOF
{ inputs, self, ... }:

let
  hostname = "${HOST_NAME}";
in

{

  flake.homeConfigurations = {

    "pim@${HOST_NAME}" = self.lib.makeHomeConf {
      inherit hostname;
    };
  };

  flake.nixosConfigurations = {

    ${HOST_NAME} = self.lib.makeNixos {
      inherit hostname;
      system = "${HOST_ARCH}";
    };
  };

  flake.modules.nixos.${HOST_NAME} = { config, pkgs, ... } : {
    system.stateVersion = "25.11";

    imports = with inputs.self.modules.nixos; [

      system-default
${ROLES_IMPORTS}
    ];

    # --- Extracted from $CFG_SOURCE ---
    # Review and remove what is already covered by shared modules above

${CFG_BODY}

  };

}
CFGEOF

  # --- networking.nix ---
  cat > "$HOST_DIR/networking.nix" <<NETEOF
{
...
}:
let
  hostname = "${HOST_NAME}";
in
{
  flake.modules.nixos.${HOST_NAME} = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.firewall.enable = false;

  };
}
NETEOF

  # If role-nebula-node was selected, run nebula cert generation
  for role in "${SELECTED_ROLES[@]}"; do
    if [[ "$role" == "role-nebula-node" ]]; then
      new_nebula_node
      break
    fi
  done

  # Success message
  echo
  gum style --border normal --padding "1 2" --border-foreground 212 \
    "✓ Created host configuration for $HOST_NAME" \
    "" \
    "Files created:" \
    "  • $HOST_DIR/configuration.nix" \
    "  • $HOST_DIR/hardware.nix" \
    "  • $HOST_DIR/networking.nix" \
    "" \
    "Roles: $ROLES_DISPLAY" \
    "" \
    "Next steps:" \
    "  1. Review hardware.nix and adjust as needed" \
    "  2. Add host-specific modules to configuration.nix imports" \
    "  3. Run: ./RUNME.sh up_machine"
  echo
}
