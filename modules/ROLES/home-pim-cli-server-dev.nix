{
inputs,
...
}:
{
  # Additive "dev server" layer: tooling for interactive development on a
  # remote server over SSH. Composed ALONGSIDE role-pim-cli-minimal (it does
  # not re-import minimal), matching the sibling-role style of the other
  # role-pim-cli-* roles. Kept deliberately lean — see the membership rule in
  # openspec change add-pim-cli-server-dev-role: only interactive remote-dev
  # tooling belongs here (Claude Code now; mosh etc. later), not GUI/desktop
  # tools and not the heavier cli-full-only tools.
  flake.modules.homeManager.role-pim-cli-server-dev = {

    imports = with inputs.self.modules.homeManager; [
      vibecoding-claude-code-config
    ];

  };
}
