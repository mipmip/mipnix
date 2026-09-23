{ self, ... }:
{
  flake.deploy = self.lib.makeDeployNode {
    hostname = "durer";
    ip = "192.168.100.12";
    system = "x86_64-linux";
  };
}
