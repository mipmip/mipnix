{ inputs, self, ... }:
{
  flake.deploy = {
    nodes.durer = {
      hostname = "192.168.100.7";
      sshUser = "pim";
      autoRollback = true;
      magicRollback = true;

      profiles.system = {
        user = "root";
        path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos
          self.nixosConfigurations.durer;
      };
    };
  };
}
