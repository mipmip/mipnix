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
