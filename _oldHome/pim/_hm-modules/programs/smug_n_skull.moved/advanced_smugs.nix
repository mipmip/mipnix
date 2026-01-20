{makeBanner, ...}:
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
        name = "mipnixvim";
        root = "~/mipnixvim";
        layout = "main-vertical";
        commands = [ (makeBanner "mipnixvim") ];
      }
    ];
  };

  quiqr-dev-run = {
    root = "~/cQuiqr";
    windows = [
      {
        root = "~/cQuiqr/quiqr-desktop";
        name = "Quiqr Desktop Legacy";
        layout = "main-horizontal";
        commands = [
          (makeBanner "quiqr-desktop-legacy")
          "nix develop"
          "npm run _electron-dev"
        ];
        panes = [{
          type = "horizontal";
          commands = [
            (makeBanner "quiqr-desktop-legacy")
            "nix develop"
            "NODE_OPTIONS=--openssl-legacy-provider npm run _react-dev"
          ];
        }];
      }

      {
        name = "nextgen";
        root = "~/cQuiqr/quiqr-desktop-ng";
        layout = "main-horizontal";
      }
      {
        name = "nextgen-upstream";
        root = "~/cQuiqr/quiqr-desktop-ng-upstream";
        layout = "main-horizontal";
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
