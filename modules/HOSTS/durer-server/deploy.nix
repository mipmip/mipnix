{ inputs, self, ... }:
{
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
