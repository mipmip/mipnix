{ inputs, self, ... }:
{
  # deploy-rs node for durer. Built on the local machine (lego2, native
  # x86_64-linux, big disk) and the realised closure is copied to durer; durer
  # cannot hold the voorzetramenshop build footprint. Activation runs over
  # durer's passwordless sudo. magicRollback reverts the previous generation if
  # durer does not confirm reachability after activation — durer is reachable
  # only over the Nebula mesh, so a bad switch must self-heal.
  #
  # Set via flake-parts' `flake.deploy = { … }` escape hatch (flake-parts has no
  # native `deploy` option, and this is NOT a perSystem output). flake-parts'
  # freeform `flake` type is `lazyAttrsOf (unique raw)`, so `deploy` must be set
  # as a WHOLE value in a single module — not piecewise as `flake.deploy.nodes…`.
  #
  # Drive with `rme deploy_remote durer` (see RUNME.d/deploy.sh). The lock must
  # be current first: `nix flake update voorzetramenshop` as pim (agent live).
  flake.deploy = {
    nodes.durer = {
      hostname = "192.168.100.12";
      sshUser = "pim";
      autoRollback = true;
      magicRollback = true;

      profiles.system = {
        user = "root";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos
          self.nixosConfigurations.durer;
      };
    };
  };
}
