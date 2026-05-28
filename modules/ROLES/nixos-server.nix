{
inputs,
...
}:
{
  flake.modules.nixos.role-server = {

    boot.kernelParams = [ "consoleblank=60" ];
    programs.mosh.enable = true;

    imports = with inputs.self.modules.nixos; [
    ];
  };
}

