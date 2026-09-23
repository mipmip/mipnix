{ self, ... }:
{
  flake.deploy = self.lib.makeDeployNode {
    hostname = "harry";
    ip = "192.168.100.7";
    system = "aarch64-linux";
  };
}
