{ self, ... }:
{
  flake.deploy = self.lib.makeDeployNode {
    hostname = "dapperehaan";
    #ip = "192.168.100.2";
    ip = "192.168.2.22";
    system = "x86_64-linux";
  };
}
