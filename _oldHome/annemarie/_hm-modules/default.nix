{ ... }:

{
  imports = []
  ++
    map (n: "${../../_generic-for-contribution}/${n}") (builtins.attrNames (builtins.readDir ./../../_generic-for-contribution))
   ++
    map (n: "${./fonts}/${n}") (builtins.attrNames (builtins.readDir ./fonts))
  ++
    map (n: "${./gnome}/${n}") (builtins.attrNames (builtins.readDir ./gnome))
  ++
    map (n: "${./programs}/${n}") (builtins.attrNames (builtins.readDir ./programs))
  ++
    map (n: "${../../_roles}/${n}") (builtins.attrNames (builtins.readDir ./../../_roles));
}
