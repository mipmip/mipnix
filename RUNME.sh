#!/usr/bin/env sh
#(C)2019-2026 Pim Snel - https://github.com/mipmip/RUNME.sh
ALLARGS=("$@");CMDS=();DESC=();NARGS=$#;ARG1=$1;make_command(){ CMDS+=($1);DESC+=("$2");};usage(){ printf "\nUsage: %s [command]\n\nCommands:\n" $0;line="                      ";for((i=0;i<=$(( ${#CMDS[*]} -1));i++));do printf "  %s %s ${DESC[$i]}\n" ${CMDS[$i]} "${line:${#CMDS[$i]}}";done;echo;};runme(){ if test $NARGS -gt 0;then eval "$ARG1"||usage;else usage;fi;}

EXTRA_ARG=$2

make_command "rekey" "Rekey all age secrets (single passphrase prompt)"
rekey(){
  with_age_identity _rekey_inner
}
_rekey_inner(){
  (cd secrets && agenix --rekey -i "$AGE_IDENTITY")
}

make_command "nix_clean" "Run nix garbage collector"
nix_clean(){
  sudo nix-collect-garbage -d
  nix-collect-garbage -d
  sudo rm -Rf /root/.cache/nix/eval-cache-v2
}
make_command "nix_clean_yesterday" "Run nix garbage collector delete yesterday and older"
nix_clean_yesterday(){
  sudo nix-collect-garbage --delete-older-than 1d
  nix-collect-garbage -d
  sudo rm -Rf /root/.cache/nix/eval-cache-v2
}

make_command "nix_optimise" "Run nix store optimise"
nix_optimise(){
  sudo nix store optimise
}

make_command "reload_tmux" "Reload TMUX Configuration"
reload_tmux(){
  tmux source ~/.config/tmux/tmux.conf
}

with_age_identity(){
  AGE_IDENTITY=$(mktemp)
  trap "shred -u \"$AGE_IDENTITY\" 2>/dev/null" RETURN
  cp ~/.ssh/id_ed25519 "$AGE_IDENTITY"
  chmod 600 "$AGE_IDENTITY"
  if ! ssh-keygen -p -N "" -f "$AGE_IDENTITY"; then
    echo "Error: Failed to decrypt SSH key"
    return 1
  fi
  "$@"
}

check_untracked(){
  # Check for untracked files only
  if [[ -n $(git status --porcelain | grep '^??') ]]; then
    echo "Error: There are untracked files. Please add or remove them first."
    git status --short | grep '^??'
    exit 1
  fi
}

make_command "git_sync_machine" "Commit latest version with hostname tag"
git_sync_machine(){
  if [[ -z "$EXTRA_ARG" ]]; then
    echo "Please enter a small commit message"
    exit 1
  fi
  git commit -m "$EXTRA_ARG" -a
  TAG_NAME="$(hostname)-$(date --iso-8601)"
  # Remove existing tag locally and remotely if it exists
  git tag -d "$TAG_NAME" 2>/dev/null || true
  git push origin --delete "$TAG_NAME" 2>/dev/null || true
  # Create new tag and push
  git tag "$TAG_NAME"
  git push origin "$TAG_NAME"
  git push
}

make_command "up_home" "Add latest home-manager updates"
up_home(){

  if ! command -v hmrice >/dev/null 2>&1
  then
    check_untracked
  else
    RICING=$(hmrice status | grep RICING | wc -l)
    if [ $RICING -gt 0 ]; then
      echo "Unrise first (hmrice unrice), then run again"
      exit 1
    else
      check_untracked
    fi
  fi

  home-manager switch --impure --flake .\#$USER@$(hostname) -b backup-$(date --iso-8601)

  # Only sync if home-manager succeeded
  if [ $? -eq 0 ]; then
    EXTRA_ARG="auto run after home-manager switch"
    git_sync_machine
  else
    echo "home-manager switch failed, skipping git sync"
    exit 1
  fi
  tmux source-file ~/.config/tmux/tmux.conf

}

make_command "up_machine" "Rebuild NixOS system configuration"
up_machine(){

  check_untracked

  HOSTNAME=$(hostname)
  # List of hostnames that need resource limitations
  LIMITED_HOSTS="harry hurry"

  if echo "$LIMITED_HOSTS" | grep -wq "$HOSTNAME"; then
    sudo nixos-rebuild switch --flake .#$HOSTNAME --max-jobs 1 -j 1 --cores 1
  else
    sudo nixos-rebuild switch --flake .#$HOSTNAME
  fi

  # Only sync if nixos-rebuild succeeded
  if [ $? -eq 0 ]; then
    EXTRA_ARG="auto run after nixos-rebuild switch"
    git_sync_machine
  else
    echo "nixos-rebuild failed, skipping git sync"
    exit 1
  fi
}

# MACHINE BOOTSTRAP COMMAND
make_command "setup_aws_key" "bootstrap AWS configuration on new machine"
setup_aws_key(){
  mkdir -p ~/.aws
  chmod 700 ~/.aws

  if [ -f ~/.aws/credentials ]; then
    cp ~/.aws/credentials ~/.aws/credentials.bak
    chmod 600 ~/.aws/credentials.bak
  fi
  age --decrypt -i ~/.ssh/id_ed25519 ./secrets/aws-credentials-copy.age > ~/.aws/credentials
  chmod 600 ~/.aws/credentials

  if [ -f ~/.aws/config ]; then
    cp ~/.aws/config ~/.aws/config.bak
    chmod 600 ~/.aws/config.bak
  fi
  age --decrypt -i ~/.ssh/id_ed25519 ./secrets/aws-config-copy-first-time-only.age > ~/.aws/config
  chmod 600 ~/.aws/config

  copy_aws_other_accounts
  technativeawsupdate
}

make_command "txn_aws_update" "update AWS account info from technative"
txn_aws_update(){
  aws-mfa --profile technative --device arn:aws:iam::521402697040:mfa/pim@technative.nl
  aws --profile=technative-web_dns s3 cp s3://docs-mcs.technative.eu-longhorn/managed_service_accounts.json ~/.aws/
  echo "Don't forget to run home-manager again"
}

make_command "copy_aws_other_accounts" "copy AWS other accounts"
copy_aws_other_accounts(){
  age --decrypt -i ~/.ssh/id_ed25519 ./secrets/aws-accounts.json.age > ~/.aws/other_accounts.json
  chmod 600 ~/.aws/other_accounts.json
  echo "Don't forget to run home-manager again"

}

make_command "copy_privkey_to_remote" "copy personal privkey to remote host I trust"
copy_privkey_to_remote(){
  if [[ -z ${ALLARGS[1]} ]] then
    echo "enter something like pim@...."
    exit 1
  fi
  echo
  echo "making 1st SSH connection"
  ssh ${ALLARGS[1]} "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
  echo
  echo "Decrypt key for sending to remote"
  KEY="$(age --decrypt -i ~/.ssh/id_ed25519 ./secrets/pimprived.age)"
  echo
  echo "Making 2nd SSH connection"
  echo "$KEY" | ssh ${ALLARGS[1]} "cat > ~/.ssh/id_ed25519"

  echo
  echo "Making last SSH connection"
  ssh ${ALLARGS[1]} "chmod 600 ~/.ssh/id_ed25519"

  echo
  echo "Copying public key to remote"
  scp ~/.ssh/id_ed25519.pub ${ALLARGS[1]}:~/.ssh/id_ed25519.pub
}

make_command "nebula_hosts" "List all nebula hosts and their IP addresses"
nebula_hosts(){
  with_age_identity show_nebula_ip_allocation
}

_nebula_ips_from_certs(){
  # Outputs "IP NAME" lines from decrypted nebula certificates
  # Requires $AGE_IDENTITY to be set (via with_age_identity)
  TMPFILE=$(mktemp)
  trap "rm -f \"$TMPFILE\"" RETURN
  for certfile in ./secrets/nebula-*.crt.age; do
    [[ "$certfile" == *"nebula-ca.crt.age" ]] && continue
    if age --decrypt -i "$AGE_IDENTITY" "$certfile" > "$TMPFILE" 2>/dev/null; then
      INFO=$(nebula-cert print -json -path "$TMPFILE" 2>/dev/null)
      NAME=$(echo "$INFO" | python3 -c "import sys,json; d=json.load(sys.stdin)[0]['details']; print(d['name'])" 2>/dev/null)
      IP=$(echo "$INFO" | python3 -c "import sys,json; d=json.load(sys.stdin)[0]['details']; print(d.get('networks',d.get('ips',['']))[0])" 2>/dev/null)
      if [[ -n "$NAME" && -n "$IP" ]]; then
        echo "$IP $NAME"
      fi
    fi
  done
  rm -f "$TMPFILE"
}

next_free_nebula_ip(){
  # Find next free nebula IP from decrypted certificates
  USED_IPS=$(_nebula_ips_from_certs | grep -o '192\.168\.100\.[0-9]\+' | grep -o '[0-9]\+$' | sort -n | uniq)
  NEXT_IP=2
  while echo "$USED_IPS" | grep -qx "$NEXT_IP"; do
    NEXT_IP=$((NEXT_IP + 1))
  done
  echo "192.168.100.${NEXT_IP}/24"
}

show_nebula_ip_allocation(){
  # Show current IP allocation from decrypted certificates
  echo "Current nebula IP allocation:"
  _nebula_ips_from_certs | while read -r IP NAME; do
    printf "  %-20s %s\n" "$IP" "$NAME"
  done | sort -t. -k4 -n
  echo
}

make_command "new_nebula_node" "Create new nebula node certificates"
new_nebula_node(){
  with_age_identity _new_nebula_node_inner
}
_new_nebula_node_inner(){
  # Check required tools
  if ! command -v gum &> /dev/null; then
    echo "Error: gum is not installed"
    exit 1
  fi
  if ! command -v nebula-cert &> /dev/null; then
    echo "Error: nebula-cert is not installed"
    exit 1
  fi
  if ! command -v age &> /dev/null; then
    echo "Error: age is not installed"
    exit 1
  fi
  if ! command -v agenix &> /dev/null; then
    echo "Error: agenix is not installed"
    exit 1
  fi

  # Use HOST_NAME if set (called from new_host), otherwise prompt
  if [[ -n "$HOST_NAME" ]]; then
    NODE_NAME="$HOST_NAME"
  else
    NODE_NAME=$(gum input --placeholder "Enter node name (e.g., harry, lego2)")
    if [[ -z "$NODE_NAME" ]]; then
      echo "Error: Node name is required"
      exit 1
    fi
  fi

  # Check if node already exists
  if [[ -f "./secrets/nebula-$NODE_NAME.crt.age" ]] || [[ -f "./secrets/nebula-$NODE_NAME.key.age" ]]; then
    echo "Error: Certificates for node '$NODE_NAME' already exist"
    exit 1
  fi

  show_nebula_ip_allocation
  SUGGESTED_IP=$(next_free_nebula_ip)
  NODE_IP=$(gum input --placeholder "Enter nebula IP in CIDR notation" --value "$SUGGESTED_IP")
  if [[ -z "$NODE_IP" ]]; then
    echo "Error: IP address is required"
    exit 1
  fi

  # Validate CIDR notation
  if ! [[ "$NODE_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
    echo "Error: Invalid CIDR notation. Expected format: 192.168.100.5/24"
    exit 1
  fi

  # Show existing groups from nebula certificates
  EXISTING_GROUPS=""
  TMPFILE=$(mktemp)
  trap "rm -f \"$TMPFILE\"" RETURN
  for certfile in ./secrets/nebula-*.crt.age; do
    [[ "$certfile" == *"nebula-ca.crt.age" ]] && continue
    if age --decrypt -i "$AGE_IDENTITY" "$certfile" > "$TMPFILE" 2>/dev/null; then
      CERT_GROUPS=$(nebula-cert print -json -path "$TMPFILE" 2>/dev/null | python3 -c "import sys,json; g=json.load(sys.stdin)[0]['details'].get('groups',[]); print(','.join(g) if g else '')" 2>/dev/null)
      if [[ -n "$CERT_GROUPS" ]]; then
        EXISTING_GROUPS="${EXISTING_GROUPS}${EXISTING_GROUPS:+,}${CERT_GROUPS}"
      fi
    fi
  done
  rm -f "$TMPFILE"
  trap - RETURN

  if [[ -n "$EXISTING_GROUPS" ]]; then
    # Deduplicate and sort
    UNIQUE_GROUPS=$(echo "$EXISTING_GROUPS" | tr ',' '\n' | sort -u | tr '\n' ',' | sed 's/,$//')
    echo "Existing nebula groups: $UNIQUE_GROUPS"
  else
    echo "No existing nebula groups found (or could not decrypt certificates)"
  fi

  NODE_GROUPS=$(gum input --placeholder "Enter groups (comma-separated, or leave empty)")

  # Confirmation
  gum style --border normal --padding "1 2" --border-foreground 33 \
    "Creating nebula certificate for:" \
    "  Node: $NODE_NAME" \
    "  IP: $NODE_IP" \
    "  Groups: ${NODE_GROUPS:-none}"

  if ! gum confirm "Proceed with certificate creation?"; then
    echo "Cancelled"
    exit 0
  fi

  # Create secure temporary directory
  TMPDIR=$(mktemp -d -t nebula-XXXXXXXXXX)
  chmod 700 "$TMPDIR"

  # Trap to ensure cleanup on exit
  trap "shred -u \"$TMPDIR\"/* 2>/dev/null; rm -rf \"$TMPDIR\"" EXIT

  echo
  echo "Decrypting CA certificates..."

  # Decrypt CA key and certificate
  if ! age --decrypt -i "$AGE_IDENTITY" ./secrets/nebula-ca.key.age > "$TMPDIR/ca.key"; then
    echo "Error: Failed to decrypt CA key"
    exit 1
  fi
  chmod 600 "$TMPDIR/ca.key"

  if ! age --decrypt -i "$AGE_IDENTITY" ./secrets/nebula-ca.crt.age > "$TMPDIR/ca.crt"; then
    echo "Error: Failed to decrypt CA certificate"
    exit 1
  fi
  chmod 600 "$TMPDIR/ca.crt"

  echo "Generating node certificates..."

  # Generate certificate
  SIGN_CMD="nebula-cert sign -ca-crt \"$TMPDIR/ca.crt\" -ca-key \"$TMPDIR/ca.key\" -name \"$NODE_NAME\" -ip \"$NODE_IP\" -out-crt \"$TMPDIR/$NODE_NAME.crt\" -out-key \"$TMPDIR/$NODE_NAME.key\""

  if [[ -n "$NODE_GROUPS" ]]; then
    SIGN_CMD="$SIGN_CMD -groups \"$NODE_GROUPS\""
  fi

  if ! eval "$SIGN_CMD"; then
    echo "Error: Failed to generate certificates"
    exit 1
  fi

  echo "Encrypting certificates..."

  # Encrypt the new certificate files
  if ! age --encrypt -R ~/.ssh/id_ed25519.pub < "$TMPDIR/$NODE_NAME.crt" > "./secrets/nebula-$NODE_NAME.crt.age"; then
    echo "Error: Failed to encrypt certificate"
    exit 1
  fi
  chmod 600 "./secrets/nebula-$NODE_NAME.crt.age"

  if ! age --encrypt -R ~/.ssh/id_ed25519.pub < "$TMPDIR/$NODE_NAME.key" > "./secrets/nebula-$NODE_NAME.key.age"; then
    echo "Error: Failed to encrypt key"
    exit 1
  fi
  chmod 600 "./secrets/nebula-$NODE_NAME.key.age"

  echo "Updating secrets.nix..."

  # Add entries to secrets.nix before the closing brace
  sed -i "/^}$/i \  \"nebula-$NODE_NAME.crt.age\".publicKeys = users ++ systems;\n  \"nebula-$NODE_NAME.key.age\".publicKeys = users ++ systems;\n" ./secrets/secrets.nix

  # Success message
  echo
  gum style --border normal --padding "1 2" --border-foreground 212 \
    "✓ Created nebula certificates for $NODE_NAME" \
    "" \
    "Files created:" \
    "  • secrets/nebula-$NODE_NAME.key.age" \
    "  • secrets/nebula-$NODE_NAME.crt.age" \
    "  • Updated secrets/secrets.nix" \
    "" \
    "Run './RUNME.sh rekey' to re-encrypt for all authorized systems" \
    "" \
    "Next steps:" \
    "  1. Add age.secrets configuration in hosts/$NODE_NAME/nebula.nix" \
    "  2. Configure services.nebula.networks.mesh in the same file" \
    "  3. Commit changes to git" \
    "  4. Rebuild the system configuration"
  echo
}

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

runme
