set fish_greeting # Disable greeting

set -l nix_shell_info (
if test -n "$IN_NIX_SHELL"
  echo -n "<nix-shell> "
end
)

function fish_prompt
  set -l prompt_symbol '$'
  fish_is_root_user; and set prompt_symbol '#'

  echo -s (prompt_hostname) (set_color blue) (prompt_pwd) (set_color yellow) $prompt_symbol (set_color normal)
end

bass source /tmp/openai-api-key
bass source /tmp/bedrockpim-api-keys-env
bass source /tmp/bedrock-keys-for-avante-env

bass export PATH=~/.npm-packages/bin:$PATH

