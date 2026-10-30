{ self, ... }:
{
  flake.deploy = self.lib.makeDeployNode {
    hostname = "dapperehaan";
    ip = "192.168.100.2";
    system = "x86_64-linux";
  };
}
