{
  home = {
    base_dir = "~";
    repos = [
      { source = "mipmip/secondbrain"; }
      { source = "mipmip/mipnixvim"; }
      { source = "mipmip/nixos"; }
    ];
  };
  quiqr = {
    base_dir = "~/cQuiqr";
    repos = [
      { source = "quiqr/embgit"; }
      { source = "quiqr/model-partials"; }
      { source = "quiqr/quiqr-book"; }
      { source = "quiqr/quiqr-community-templates"; }
      { source = "quiqr/quiqr-desktop"; }
      { source = "quiqr/quiqr.org"; }
      { source = "mipmip/github-action-markdown-link-extract-to-json"; }
      { source = "quiqr/mipmip/intergram"; }
    ];
  };

  technative = {
    base_dir = "~/tcCustomers/aws-technative";
    repos = [
      {
        source =
          "TechNative-B-V/technative-awsaccount-617813585939-management";
      }
      {
        source =
          "TechNative-B-V/technative-awsaccount-521402697040-useraccount";
      }
      {
        source =
          "TechNative-B-V/technative-awsaccount-393573040164-webdns";
      }
      {
        source =
          "TechNative-B-V/technative-awsaccount-393573040164-webdns-ec2nix";
      }
      {
        source =
          "TechNative-B-V/technative-awsaccount-668886465434-account-manager";
      }
      {
        source =
          "TechNative-B-V/technative-awsaccount-076504012268-student-007-pim";
      }
      {
        source =
          "TechNative-B-V/terraform-aws-module-static-website-cognito-auth";
      }
    ];

  };

}
