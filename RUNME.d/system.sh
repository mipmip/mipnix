make_command "reload_tmux" "Reload TMUX Configuration"
reload_tmux(){
  tmux source ~/.config/tmux/tmux.conf
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

  mkdir -p ~/.aws
  chmod 700 ~/.aws
  if ! [[ -f ~/.aws/other_accounts.json ]]; then
    echo "[]" > ~/.aws/other_accounts.json
  fi
  if ! [[ -f ~/.aws/managed_service_accounts.json ]]; then
    echo "[]" > ~/.aws/managed_service_accounts.json
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

  if command -v tmux >/dev/null 2>&1
  then
    tmux source-file ~/.config/tmux/tmux.conf
  fi

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

make_command "up_machine_trace" "Rebuild NixOS system configuration (with full trace)"
up_machine_trace(){

  check_untracked

  HOSTNAME=$(hostname)
  LIMITED_HOSTS="harry hurry"

  if echo "$LIMITED_HOSTS" | grep -wq "$HOSTNAME"; then
    sudo nixos-rebuild switch --flake .#$HOSTNAME --max-jobs 1 -j 1 --cores 1 --show-trace 2>&1 | tee /tmp/nixos-rebuild-trace.log
  else
    sudo nixos-rebuild switch --flake .#$HOSTNAME --show-trace 2>&1 | tee /tmp/nixos-rebuild-trace.log
  fi

  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    EXTRA_ARG="auto run after nixos-rebuild switch"
    git_sync_machine
  else
    echo ""
    echo "nixos-rebuild failed. Full trace saved to /tmp/nixos-rebuild-trace.log"
    exit 1
  fi
}
