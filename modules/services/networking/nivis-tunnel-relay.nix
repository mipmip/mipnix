# The nivis-tunnel rendezvous relay.
#
# nivis-tunnel exists to reach a machine that has no inbound port: the agent on
# the target and the orchestrator both dial outward, and this relay pairs them
# by stream id and copies bytes between them. Noise runs end to end through it,
# so a relay operator holds no key material and cannot read what it carries.
#
# That is what makes hosting one cheap to reason about, and it is also the whole
# security argument: there is nothing here to steal and nothing to read. What
# there is, is an open port on a machine that also serves other things — so the
# port is opened explicitly below rather than by the module, and the bounds that
# keep an unauthenticated service standing are left at their defaults.
{ inputs, ... }:
{
  flake.modules.nixos.networking-nivis-tunnel-relay =
    { ... }:
    {
      imports = [ inputs.nivis-tunnel.nixosModules.relay ];

      services.nivis-tunnel-relay = {
        enable = true;
        port = 7843;

        # The module defaults this to false on purpose, because NixOS firewall
        # port lists merge rather than override and a module that opens a port
        # quietly can leave a machine reachable that its own configuration says
        # should not be. A relay that nobody can reach is useless, so here it is
        # deliberate.
        openFirewall = true;
      };
    };
}
