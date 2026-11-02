{ ... }:
{
  # Services on machines that are not NixOS hosts, so no module of their own
  # can register them.
  lobby.services.piethein = {
    title = "piethein (DSM)";
    description = "Synology DSM; not a NixOS host";
    host = "piethein";
    url = "https://192.168.2.100:5001";
    access = "lan";
    category = "files & sync";
  };
}
