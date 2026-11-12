{makeBanner, pkgs, ...}:
{

  sudo = {
    windows = [{
      name = "root";
      layout = "main-vertical";
      commands = [ (makeBanner "root") "sudo su -" ];
    }];
  };

  nixos = {
    root = "~/mipnix";
    windows = [
      {
        name = "mipnix";
        layout = "main-vertical";
        commands = [ (makeBanner "mipnix") ];

        panes = [
          {
            type = "horizontal";
            commands = [ (makeBanner "mipnix")  ];
          }
          {
            type = "horizontal";
            commands = [ (makeBanner "mipnix")  ];
          }
        ];

      }
      {
        name = "secrets";
        root = "~/mipnix/secrets";
        layout = "main-vertical";
        commands = [ (makeBanner "nixos secrets") ];
      }
    ];
  };

  monitoring = {
    root = "~/cMonitoring";
    windows = [

      {
        name = "CoreVitals";
        layout = "tiled";
        commands = [
          "${pkgs.btop}/bin/btop"
        ];

        panes = [
          {
            type = "horizontal";
            commands = [ "${pkgs.claude-monitor}/bin/claude-monitor --plan max5" ];
          }
        ];
      }

    ];
  };

  doen = {
    root = "~/secondbrain";
    windows = [
      {
        name = "doen";
        layout = "main-horizontal";
        commands = [ "nlin" ];
      }
      {
        name = "sync";
        layout = "main-horizontal";
        commands = [ "watch -n 10 git-sync -n" ];
      }
    ];
  };
}
