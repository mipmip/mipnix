{
inputs,
...
}:
{
  flake.modules.nixos.role-server = {

    boot.kernelParams = [ "consoleblank=60" ];

    imports = with inputs.self.modules.nixos; [
    ];
  };
}

