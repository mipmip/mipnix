make_command "nebula_hosts" "List all nebula hosts and their IP addresses"
nebula_hosts(){
  with_age_identity show_nebula_ip_allocation
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
