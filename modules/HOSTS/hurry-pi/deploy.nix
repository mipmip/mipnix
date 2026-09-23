{ self, ... }:
{
  flake.deploy = self.lib.makeDeployNode {
    hostname = "hurry";
    ip = "192.168.100.6";
    system = "aarch64-linux";
  };
}
