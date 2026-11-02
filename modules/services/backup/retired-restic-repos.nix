{ ... }:
{
  # Restic repositories of hosts that no longer exist. Their data stays on
  # piethein, and registering the names here keeps them in Backrest for restores.
  flake.resticRepos.cichorei = [
    "cichorei-claude"
    "cichorei-documents"
    "cichorei-secondbrain"
    "cichorei-ssh"
  ];
}
