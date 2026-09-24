{
inputs,
...
}:
{
  flake.modules.homeManager.pim-ragenx = { pkgs, ... }: {

    # ragenx edits, decrypts and rekeys agenix secrets using an ssh key held in
    # rbw, injected through an in-memory pipe rather than written to disk.
    #
    # agenix (Go-age) reads private keys only as files and has no ssh-agent
    # support, so a key kept deliberately out of the filesystem cannot be used
    # with agenix directly. ragenx is that bridge.
    #
    # Needs rbw, which pim-rbw installs; the roles import both.
    home.packages = [
      inputs.ragenx.packages."${pkgs.stdenv.hostPlatform.system}".default
    ];
  };
}
