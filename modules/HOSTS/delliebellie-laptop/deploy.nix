{ self, ... }:
{
  flake.deploy = self.lib.makeDeployNode {
    hostname = "delliebellie";
    ip = "192.168.100.3";
    system = "x86_64-linux";
  };
}
