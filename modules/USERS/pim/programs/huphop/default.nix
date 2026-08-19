{
inputs,
...
}:
{
  flake.modules.homeManager.pim-huphop = { lib, pkgs, ... }:
    let
      # Model B switch wrapper: session per org, window per repo. huphop renders
      # switch_command as a template then execs it WITHOUT a shell, so all
      # branching must live here in a single executable. Only tmux server
      # commands are issued (no TTY needed) — it runs while huphop's TUI still
      # owns the terminal, then the TUI quits and the popup closes.
      # Args: <short> <owner> <repo> <target-checkout-path>
      hup-tmux-switch = pkgs.writeShellScriptBin "hup-tmux-switch" ''
        short="$1"; owner="$2"; repo="$3"; target="$4"

        tmux="${pkgs.tmux}/bin/tmux"

        # Sanitise names out of tmux's session:window.pane target grammar.
        sess="$(printf '%s->%s' "$short" "$owner" | tr ':.' '--')"
        win="$(printf  '%s' "$repo"               | tr ':.' '--')"

        if ! "$tmux" has-session -t "=$sess" 2>/dev/null; then
          "$tmux" new-session -d -s "$sess" -n "$win" -c "$target"
        elif ! "$tmux" list-windows -t "=$sess" -F '#W' | grep -qx "$win"; then
          "$tmux" new-window -d -t "=$sess" -n "$win" -c "$target"
        fi

        "$tmux" switch-client -t "=$sess:$win"
      '';

      # Reproduces the current working ~/.config/huphop/config.yaml verbatim,
      # except the multiplex switch_command, which points at the wrapper above
      # by store path (hermetic — no PATH dependency).
      hupConfig = {
        base_dir = "~";
        clone_pattern_tpl = "{{.BaseDir}}/{{.Short}}.{{.OwnerLower}}/{{.Repo}}";
        search_strategy= "substring";
        providers = [
          {
            name = "github";
            type = "github";
            short = "gh";
            username = "mipmip";
            web_url = "https://github.com";
            clone_protocol = "ssh";
            auth = {
              cli = "gh";
              env = "HUPHOP_GITHUB_TOKEN";
            };
            all_owners = true;
            include_archived = false;
            include_forks = true;
          }
        ];

        default_mode = "management";
        modes = {
          management = {
            header = [ "breadcrumb" ];
            footer = [ "filter" "facet_status" "status_message" "position_indicator" "action_menu" ];
          };
          multiplex = {
            header = [ ];
            footer = [ "switch_hint" "filter" ];
            switch_command =
              "'${hup-tmux-switch}/bin/hup-tmux-switch' '{{.Short}}' '{{.OwnerLower}}' '{{.Repo}}' '{{.Target}}'";
          };
        };
      };
    in
    {
      home.packages = [
        inputs.huphop.packages."${pkgs.stdenv.hostPlatform.system}".default
      ];

      xdg.configFile."huphop/config.yaml".source =
        (pkgs.formats.yaml { }).generate "huphop-config.yaml" hupConfig;
    };
}
