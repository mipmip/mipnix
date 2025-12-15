[
    {
      root = "~/tcUniversity";
      name = "technative-we-are";
      repos = [

        { source = "wearetechnative/terraform-aws-network"; }
        { source = "wearetechnative/terraform-aws-kms"; }
        { source = "wearetechnative/terraform-aws-ecs"; }
        { source = "wearetechnative/terraform-aws-sqs-dlq"; }
        { source = "wearetechnative/terraform-aws-ec2-asg"; }
        { source = "wearetechnative/terraform-aws-iam-role"; }
        { source = "wearetechnative/terraform-null-url-parser"; }
        { source = "wearetechnative/awesome-technative"; }
        { source = "wearetechnative/awesome-finops"; }
        { source = "wearetechnative/awesome-flake-parts"; }
      ];
    }
    {
      name = "technative-university";
      root = "~/tcUniversity";
    }
    {
      name = "technative-docs";
      root = "~/tcTNxDocs";
      repos = [
        { source = "TechNative-B-V/technative-project-proposals"; }
        { source = "TechNative-B-V/technative-project-operational-excellence"; }
        { source = "TechNative-B-V/technative-docs-managed-services-handbook"; }
        { source = "TechNative-B-V/technative-docs-marcom-handbook"; }
      ];

    }
    {
      name = "lobby";
      root = "~/tcTNxDocs";
    }
    {
      name = "nixdev";
      root = "~/cNixos";
      repos = [{ source = "mipmip/home-manager-option-search"; }];
    }
    {
      name = "gnome";
      root = "~/cGnome";
      repos = [
        { source = "mipmip/gnome-hotkeys.cr"; }
        { source = "mipmip/gnome-shell-extensions-highlight-focus"; }
        { source = "mipmip/gnome-shell-extensions-hotkeys-popup"; }
        { source = "mipmip/gnome-shell-extensions-useless-gaps"; }
      ];
    }

    {
      name = "github";
      root = "~/cGithub";
      repos = [
        { source = "mipmip/mipmip"; }
        { source = "mipmip/g.it-depends"; }
        { source = "mipmip/github-admin"; }
        { source = "mipmip/skull"; }
      ];
    }

    {
      name = "forks";
      root = "~/cForks";
      repos = [
        { source = "mipmip/hugoDocs"; }
        { source = "mipmip/hugo"; }
        { source = "mipmip/nixpkgs"; }
        { source = "mipmip/NUR"; }
        { source = "mipmip/nur-search"; }
        { source = "mipmip/octokit.cr"; }
        { source = "mipmip/sc-im"; }
        { source = "mipmip/smug"; }
        { source = "mipmip/nixos-homepage"; }
      ];
    }

    {
      name = "linden";
      root = "cLinden";
      repos = [
        { source = "linden-project/linden-project.github.io"; }
        { source = "linden-project/fred"; }
        { source = "linden-project/linny-notebook-template"; }
        { source = "linden-project/linny.vim"; }
        { source = "mipmip/mip.rs"; }

      ];

    }

    {
      name = "PimMarketingEco";
      root = "~/cPimMarketingEco";
      repos = [
        { source = "mipmip/pimspiratie_bot"; }
        { source = "mipmip/pimterest-data"; }
        { source = "mipmip/pimterest.github.io"; }
      ];
    }

    {
      name = "privops";
      root = "~/cPrivateOps";
      repos = [
        { source = "snel-city/wasnel-awsaccount-104144963194-main"; }
        {
          source =
            "snel-city/wasnel-awsaccount-104144963194-ec2nix-net-db-storage";
        }
        { source = "snel-city/wasnel-awsaccount-104144963194-ec2nix-dockers1"; }
      ];

    }

    {
      name = "inkscape";
      root = "~/cInkscape";
      repos = [
        { source = "wearetechnative/cloudia"; }
        { source = "mipmip/inkscape-cloud-architect"; }
        { source = "mipmip/awesome-inkscape"; }
      ];
    }
    {
      name = "quiqr-data";
      root = "~/Quiqr Data/sites";
    }
  ]
