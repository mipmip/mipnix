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
        commands = [ (makeBanner "nixos") ];
      }
      {
        name = "secrets";
        root = "~/mipnix/secrets";
        layout = "main-vertical";
        commands = [ (makeBanner "nixos secrets") ];
      }
      {
        name = "mipnix";
        root = "~/mipnix";
        layout = "main-vertical";
        commands = [ (makeBanner "mipnix") ];
      }
    ];
  };

  monitoring = {
    root = "~/cMonitoring";
    windows = [

      {
        name = "CoreVitals";
        layout = "main-vertical";
        commands = [ "${pkgs.btop}/bin/btop" ];

        panes = [
          {
            type = "horizontal";
            commands = [
              "${pkgs.claude-monitor}/bin/claude-monitor"
            ];
          }
          {
            type = "horizontal";
            commands = [ "nix run github:mipmip/updo -- monitor https://slashdot.org" ];
          }
        ];
      }

    ];
  };



  quiqr-dev-run = {
    root = "~/cQuiqr";
    windows = [

      {
        root = "~/cQuiqr/quiqr-desktop-mipmip";
        name = "Quiqr Mipmip";
        layout = "main-vertical";
        commands = [
          (makeBanner "quiqr mipmip")
          "nix develop -c $SHELL"
        ];
      }

      {
        root = "~/cQuiqr/quiqr-desktop-upstream";
        layout = "main-vertical";
        name = "Quiqr Upstream";
        commands = [
          (makeBanner "quiqr upstream")
          "nix develop -c $SHELL"
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

        panes = [{
          type = "horizontal";
          commands = [
            "hugo server --ignoreCache --forceSyncStatic --cleanDestinationDir --disableFastRender -e private -p 1314"
          ];
        }];
      }
    ];
  };
}
