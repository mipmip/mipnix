{ mipColors, ... }:
{
  extraConfigLua = ''
    vim.api.nvim_set_hl(0, 'NormalNC', { bg = '${mipColors.bg.inactive}' })
  '';
}
