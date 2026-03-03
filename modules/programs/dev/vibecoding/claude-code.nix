{ inputs, ... }: {
  flake.modules.homeManager.vibecoding-claude-code = { lib, config, pkgs, ... }:
    with lib;
    let
      cfg = config.programs.claude-code;

      # Hook configurations
      defaultHooks = {
        # Notify when Claude requests tool permission
        beforeToolCall = {
          command = "${pkgs.libnotify}/bin/notify-send";
          args = [
            "Claude Code"
            "Requesting permission for: {{toolName}}"
            "-u" "normal"
            "-t" "8000"
            "-i" "dialog-information"
          ];
        };

        # Notify when waiting for user input
        onPrompt = {
          command = "${pkgs.libnotify}/bin/notify-send";
          args = [
            "Claude Code"
            "⏸️  Waiting for your input..."
            "-u" "critical"
            "-t" "0"  # Don't auto-dismiss
            "-i" "dialog-question"
          ];
        };

        # Notify on errors
        onError = {
          command = "${pkgs.libnotify}/bin/notify-send";
          args = [
            "Claude Code Error"
            "❌ {{errorMessage}}"
            "-u" "critical"
            "-t" "10000"
            "-i" "dialog-error"
          ];
        };

        # Optional: Notify when tasks complete
        afterToolCall = mkIf cfg.notifications.verboseMode {
          command = "${pkgs.libnotify}/bin/notify-send";
          args = [
            "Claude Code"
            "✅ Completed: {{toolName}}"
            "-u" "low"
            "-t" "3000"
            "-i" "emblem-default"
          ];
        };
      };

      # MCP servers configuration
      mcpConfig = {
        mcpServers = cfg.mcpServers;
      };

      # Hooks configuration
      hooksConfig = {
        hooks = if cfg.notifications.enable then defaultHooks else {};
      };

    in {
      options.programs.claude-code = {
        enable = mkEnableOption "Claude Code configuration";

        notifications = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable desktop notifications for Claude Code events";
          };

          verboseMode = mkOption {
            type = types.bool;
            default = false;
            description = "Enable notifications for all tool calls (can be noisy)";
          };
        };

        mcpServers = mkOption {
          type = types.attrsOf (types.submodule {
            options = {
              command = mkOption {
                type = types.str;
                description = "Command to run the MCP server";
              };
              args = mkOption {
                type = types.listOf types.str;
                default = [];
                description = "Arguments to pass to the MCP server";
              };
              env = mkOption {
                type = types.attrsOf types.str;
                default = {};
                description = "Environment variables for the MCP server";
              };
            };
          });
          default = {};
          description = "MCP servers configuration";
        };

        customHooks = mkOption {
          type = types.attrsOf types.attrs;
          default = {};
          description = "Custom hooks to add or override default hooks";
        };
      };

      config = mkIf cfg.enable {
        # Create .claude config directory
        home.file.".claude/config/.keep".text = "";

        # Install hooks configuration
        home.file.".claude/config/hooks.json" = mkIf cfg.notifications.enable {
          text = builtins.toJSON (hooksConfig // {
            hooks = hooksConfig.hooks // cfg.customHooks;
          });
        };

        # Install MCP servers configuration
        home.file.".claude/config/mcp.json" = mkIf (cfg.mcpServers != {}) {
          text = builtins.toJSON mcpConfig;
        };

        # Ensure notification dependencies are available
        home.packages = mkIf cfg.notifications.enable [
          pkgs.libnotify
        ];
      };
    };
}
