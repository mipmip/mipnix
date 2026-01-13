local lsps = {
  { "rust_analyzer", { cmd = {"rust-analyzer"},filetypes = { 'rust' }}  },
  { "gopls",         { cmd = {"gopls"},filetypes = { 'go' }} },
  { "hls",           { cmd = { "haskell-language-server-wrapper lsp"},filetypes = { 'haskell' }} },
  { "cssls",         { cmd = { "vscode-css-language-server"},filetypes = { 'css' }} },
  { "lua_ls",        { cmd = { "lua-language-server"},filetypes = { 'lua' }} },
  { "html",          { cmd = { "vscode-html-language-server"},filetypes = { 'html' }}},
  { "jsonls",        { cmd = { "vscode-json-language-server"},filetypes = { 'json' } } },
  { "terraformls",   { cmd = { 'terraform-ls' },filetypes = { 'hcl' } }},
  { "crystalline",   { cmd = { 'crystalline' },filetypes = { 'crystal' } }},
  { "bashls",        { cmd = { 'bash-language-server' }, filetypes = { 'bash' } }},
  { "nil_ls",        { cmd = { 'nil' }, filetypes = { 'nix' }, } },
  { "ts_ls",
    {
      cmd = { 'typescript-language-server', '--stdio' },
      filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    }
  },
  {
    "marksman",
    {
      cmd = {
        "sh",
        "-c",
        "test -x /run/current-system/sw/bin/marksman && { /run/current-system/sw/bin/marksman server; } || { marksman server; }",
      },
      filetypes = { 'markdown' },
    }
  },
}


for _, lsp in pairs(lsps) do
  local name, config = lsp[1], lsp[2]
  vim.lsp.enable(name)
  if config then
    vim.lsp.config(name, config)
  end
end
