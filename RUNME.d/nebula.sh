make_command "nebula_hosts" "List all nebula hosts and their IP addresses"
nebula_hosts(){
  with_age_identity show_nebula_ip_allocation
}

# Ask whether to overwrite an existing artifact. Returns success (overwrite) when
# $FORCE is set, otherwise defers to an interactive gum confirm. Lets new_nebula_node
# prompt per artifact when re-provisioning instead of aborting or silently skipping.
_confirm_overwrite(){
  local what="$1"
  if [[ -n "$FORCE" ]]; then
    echo "$what already exists — overwriting (FORCE)"
    return 0
  fi
  gum confirm "$what already exists — overwrite?"
}

make_command "new_nebula_node" "Create new nebula node certificates"
new_nebula_node(){
  with_age_identity _new_nebula_node_inner
}
# Re-provisioning: when the node or parts of it already exist, each conflict prompts
# to overwrite. Set FORCE=1 to answer every overwrite prompt affirmatively.
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

  # If the node's certificates already exist, ask whether to regenerate (overwrite)
  # them. Declining keeps the existing certs and continues with the remaining steps,
  # so a partial or re-provisioning run can still fix secrets.nix and the wiring file.
  REGEN_CERTS="yes"
  if [[ -f "./secrets/nebula-$NODE_NAME.crt.age" ]] || [[ -f "./secrets/nebula-$NODE_NAME.key.age" ]]; then
    if _confirm_overwrite "Certificates for node '$NODE_NAME'"; then
      REGEN_CERTS="yes"
    else
      echo "Keeping existing certificates for '$NODE_NAME'"
      REGEN_CERTS="no"
    fi
  fi

  # Certificate generation (IP, groups, signing, encryption) only runs when the certs
  # are absent or the operator confirmed an overwrite above.
  if [[ "$REGEN_CERTS" == "yes" ]]; then

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

  fi  # end certificate (re)generation block

  echo "Updating secrets.nix..."

  # Add the node's cert/key publicKeys entries before the closing brace (skip if present).
  if grep -qF "\"nebula-$NODE_NAME.crt.age\".publicKeys" ./secrets/secrets.nix; then
    echo "publicKeys entries for '$NODE_NAME' already present in secrets.nix"
  else
    sed -i "/^}$/i \  \"nebula-$NODE_NAME.crt.age\".publicKeys = users ++ systems;\n  \"nebula-$NODE_NAME.key.age\".publicKeys = users ++ systems;\n" ./secrets/secrets.nix
  fi

  # --- Register the machine's host key in secrets.nix (let-binding + systems) ---
  # The node's agenix identity is its SSH ed25519 host public key. new_host runs on
  # the target machine, so read it from /etc/ssh. Degrade gracefully if unavailable.
  SECRETS_NOTE="cert/key entries"
  HOST_KEY_FILE="/etc/ssh/ssh_host_ed25519_key.pub"
  if [[ -r "$HOST_KEY_FILE" ]]; then
    MACHINE_KEY=$(cut -d' ' -f1,2 < "$HOST_KEY_FILE")
    if [[ "$MACHINE_KEY" == ssh-ed25519\ * ]]; then
      # Add the "<node> = "ssh-ed25519 …";" let-binding. If it exists with the same key,
      # skip silently; if it differs, prompt to overwrite (value only) unless FORCE.
      EXISTING_KEY=$(grep -E "^\s*${NODE_NAME}\s*=\s*\"ssh-" ./secrets/secrets.nix | head -1 | sed -E 's/^\s*[^=]+=\s*"([^"]*)".*/\1/')
      if [[ -z "$EXISTING_KEY" ]]; then
        sed -i "/^let$/a\\  ${NODE_NAME} = \"${MACHINE_KEY}\";" ./secrets/secrets.nix
        SECRETS_NOTE="cert/key entries + machine key"
      elif [[ "$EXISTING_KEY" == "$MACHINE_KEY" ]]; then
        echo "Machine key for '$NODE_NAME' already up to date in secrets.nix"
      elif _confirm_overwrite "Machine key for '$NODE_NAME' (differs from current host key)"; then
        # Replace only the quoted value on the node's binding line ('|' delimiter: key has '/').
        sed -i -E "s|^(\s*${NODE_NAME}\s*=\s*\")[^\"]*(\".*)|\1${MACHINE_KEY}\2|" ./secrets/secrets.nix
        SECRETS_NOTE="cert/key entries + machine key (updated)"
      else
        echo "Keeping existing machine key for '$NODE_NAME'"
      fi
      # Append the node to the systems list unless it is already a member. Anchor to
      # "^  systems = [" so trusted_systems is not matched.
      IN_SYSTEMS=$(awk '/^  systems = \[/{f=1;next} /^  \];/{f=0} f' ./secrets/secrets.nix | grep -E "^\s*${NODE_NAME}\s*$")
      if [[ -n "$IN_SYSTEMS" ]]; then
        echo "'$NODE_NAME' already in the systems list"
      else
        sed -i "/^  systems = \[/a\\    ${NODE_NAME}" ./secrets/secrets.nix
        [[ "$SECRETS_NOTE" == *"machine key"* ]] && SECRETS_NOTE="${SECRETS_NOTE} + systems"
      fi
    else
      echo "Warning: $HOST_KEY_FILE did not contain an ssh-ed25519 key; skipping machine key registration"
    fi
  else
    echo "Warning: could not read $HOST_KEY_FILE; skipping machine key registration for '$NODE_NAME'"
    echo "         Add the '$NODE_NAME' let-binding and systems entry to secrets/secrets.nix manually."
  fi

  # --- Generate the per-host nebula wiring file ---
  # Resolve the host directory: prefer the one new_host exports, else glob by node name.
  if [[ -n "$HOST_DIR" && -d "$HOST_DIR" ]]; then
    NODE_HOST_DIR="${HOST_DIR%/}"
  else
    _matches=(modules/HOSTS/"$NODE_NAME"-*/)
    if [[ ${#_matches[@]} -eq 1 && -d "${_matches[0]}" ]]; then
      NODE_HOST_DIR="${_matches[0]%/}"
    else
      NODE_HOST_DIR=""
    fi
  fi

  # Decide whether to (re)write the wiring file. An existing file prompts to overwrite.
  WRITE_NEBULA="yes"
  if [[ -z "$NODE_HOST_DIR" ]]; then
    echo "Warning: could not resolve a unique host directory for '$NODE_NAME' under modules/HOSTS/"
    echo "         Skipping nebula.nix generation — create it manually or re-run via new_host."
    WRITE_NEBULA="no"
  elif [[ -f "$NODE_HOST_DIR/nebula.nix" ]]; then
    if _confirm_overwrite "$NODE_HOST_DIR/nebula.nix"; then
      WRITE_NEBULA="yes"
    else
      echo "$NODE_HOST_DIR/nebula.nix left unchanged"
      WRITE_NEBULA="no"
    fi
  fi

  NEBULA_NIX_CREATED="no"
  if [[ "$WRITE_NEBULA" == "yes" ]]; then
    echo "Writing $NODE_HOST_DIR/nebula.nix..."
    cat > "$NODE_HOST_DIR/nebula.nix" <<NEBEOF
{ ... }:
{
  flake.modules.nixos.${NODE_NAME} = { config, ... }: {

    age.secrets = {
      "nebula-${NODE_NAME}-cert" = {
        file = ../../../secrets/nebula-${NODE_NAME}.crt.age;
        path = "/var/lib/nebula/nebula-${NODE_NAME}.crt";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
      "nebula-${NODE_NAME}-key" = {
        file = ../../../secrets/nebula-${NODE_NAME}.key.age;
        path = "/var/lib/nebula/nebula-${NODE_NAME}.key";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
    };

    services.nebula.networks.mesh = {
      cert = config.age.secrets."nebula-${NODE_NAME}-cert".path;
      key = config.age.secrets."nebula-${NODE_NAME}-key".path;
    };
  };
}
NEBEOF
    NEBULA_NIX_CREATED="yes"
  fi

  # Success message
  echo
  _summary=(
    "✓ Provisioned nebula node $NODE_NAME"
    ""
    "Auto-created / updated:"
    "  • secrets/nebula-$NODE_NAME.crt.age"
    "  • secrets/nebula-$NODE_NAME.key.age"
    "  • secrets/secrets.nix ($SECRETS_NOTE)"
  )
  if [[ "$NEBULA_NIX_CREATED" == "yes" ]]; then
    _summary+=("  • $NODE_HOST_DIR/nebula.nix (age.secrets + mesh cert/key wiring)")
  fi
  _summary+=(
    ""
    "Remaining manual steps:"
    "  1. Run './RUNME.sh rekey' to re-encrypt secrets for all systems"
    "  2. Commit the changes to git"
    "  3. Rebuild the system configuration"
  )
  gum style --border normal --padding "1 2" --border-foreground 212 "${_summary[@]}"
  echo
}
