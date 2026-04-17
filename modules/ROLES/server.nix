{
inputs,
...
}:
{
  flake.modules.nixos.system-default = {

    boot.kernelParams = [ "consoleblank=60" ];

    imports = with inputs.self.modules.nixos; [
    ];
  };
}

