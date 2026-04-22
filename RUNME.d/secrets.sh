make_command "rekey" "Rekey all age secrets (single passphrase prompt)"
rekey(){
  with_age_identity _rekey_inner
}
_rekey_inner(){
  (cd secrets && agenix --rekey -i "$AGE_IDENTITY")
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
