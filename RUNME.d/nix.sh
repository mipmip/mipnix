make_command "nix_clean" "Run nix garbage collector"
nix_clean(){
  sudo nix-collect-garbage -d
  nix-collect-garbage -d
  sudo rm -Rf /root/.cache/nix/eval-cache-v2
}
make_command "nix_clean_yesterday" "Run nix garbage collector delete yesterday and older"
nix_clean_yesterday(){
  sudo nix-collect-garbage --delete-older-than 1d
  nix-collect-garbage -d
  sudo rm -Rf /root/.cache/nix/eval-cache-v2
}

make_command "nix_optimise" "Run nix store optimise"
nix_optimise(){
  sudo nix store optimise
}
