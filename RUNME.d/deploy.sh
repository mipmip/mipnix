make_command "deploy_remote" "Build locally and deploy a remote host with deploy-rs"
deploy_remote(){

  # Deploys a NAMED remote host from this (build) machine — unlike up_machine,
  # which rebuilds the current host. The target is passed as an argument:
  #
  #   rme deploy_remote durer
  #
  # The closure is built here (big disk), copied to the target, and activated
  # over the target's passwordless sudo. deploy-rs magic-rollback reverts the
  # target if it does not confirm reachability after activation. The node is
  # defined in modules/HOSTS/<host>-server/deploy.nix (flake.deploy.nodes.<host>).
  #
  # When bumping a private input (e.g. voorzetramenshop), run
  #   nix flake update voorzetramenshop
  # FIRST, as your user with the SSH agent loaded, so deploy-rs evaluates an
  # already-locked input. Order is load-bearing.

  TARGET="$EXTRA_ARG"

  if [[ -z "$TARGET" ]]; then
    echo "Error: deploy_remote needs a target host, e.g. 'rme deploy_remote durer'"
    exit 1
  fi

  check_untracked

  # Build on this machine, copy the closure, activate remotely with rollback.
  # --skip-checks: deploy-rs otherwise runs `nix flake check` over the WHOLE
  # flake (every nixosConfiguration — dapperehaan, harry, …), which is slow for
  # a single-host deploy and aborts on any unrelated host's eval error. The
  # target's own build is gated separately before deploying.
  if deploy --skip-checks ".#$TARGET"; then
    EXTRA_ARG="auto run after deploy_remote $TARGET"
    # Tag the sync with the deployed host, not this build machine.
    SYNC_TARGET="$TARGET"
    git_sync_machine
  else
    echo "deploy-rs failed for '$TARGET' (it has auto-rolled-back the target if activation was reached); skipping git sync"
    exit 1
  fi
}
