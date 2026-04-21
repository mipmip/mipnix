{
inputs,
...
}:
{
  flake.modules.nixos.role-desktop-annemarie = {
    imports = with inputs.self.modules.nixos; [
      desktop-myhotkeys
      desktop-de-kde
      desktop-apps-mail
      desktop-hw-printers
      desktop-virt-virtualization
      plymouth-grannyos
      granny
    ];
  };
}

