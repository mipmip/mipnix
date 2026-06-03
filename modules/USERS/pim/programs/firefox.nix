{
inputs,
...
}:
{
  flake.modules.homeManager.pim-firefox = { pkgs, ... }: {
    programs.firefox = {
      enable = true;
      configPath = ".mozilla/firefox";
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
          CaptivePortal = false;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisableFirefoxAccounts = false;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          OfferToSaveLoginsDefault = false;
          PasswordManagerEnabled = false;
          FirefoxHome = {
            Search = true;
            Pocket = false;
            Snippets = false;
            TopSites = false;
            Highlights = false;
          };
          UserMessaging = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
          };
        };
      };
      profiles =
        let defaultSettings = {
          "browser.startup.homepage" = "about:blank";
        };
        in {
          default = {
            id = 0;
            isDefault = true;

            search = {
              force = true;
              default = "Kagi";
              engines = {
                "Kagi" = {
                  urls = [{
                    template = "https://kagi.com/search?q={searchTerms}";
                  }];
                  #icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@k" ];
                };
                "Nix Packages" = {
                  urls = [{
                    template = "https://search.nixos.org/packages";
                    params = [
                      { name = "type"; value = "packages"; }
                      { name = "query"; value = "{searchTerms}"; }
                    ];
                  }];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@np" ];
                };
                "wikipedia".metaData.alias = "@wiki";
                "google".metaData.hidden = true;
                "amazondotcom-us".metaData.hidden = true;
                "bing".metaData.hidden = true;
                "ebay".metaData.hidden = true;
              };
            };


            settings = defaultSettings // {
            };
          };

          adevinta = {
            id = 1;
            settings = defaultSettings // {
              "browser.startup.homepage" = "https://automobile.it";
            };
          };

          mahmoud = {
            id = 2;
            name = "mahmoud";
            settings = {
              "general.smoothScroll" = true;
            };
          };
        };
    };
  };
}
