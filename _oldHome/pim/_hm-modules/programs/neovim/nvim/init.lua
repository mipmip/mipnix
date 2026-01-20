vim.g.mapleader = '\\'
vim.g.maplocalleader = '\\'

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("vim-options")
require("lsp")

require("lazy").setup("plugins")

require("functions")
require("keymaps")
require("keymaps_avante")

vim.cmd('source ' .. vim.fn.stdpath("config") .. '/vimscript/hotkeys.vim')
vim.cmd('source ' .. vim.fn.stdpath("config") .. '/vimscript/environment.vim')


local wip_path = vim.fn.stdpath("config") .. '/vimscript/wip.vim'

if not vim.loop.fs_stat(wip_path) then
  vim.fn.system {
    'touch',
    wip_path,
  }
end

vim.cmd('source ' .. vim.fn.stdpath("config") .. '/vimscript/wip.vim')

vim.api.nvim_create_augroup("neotree", {})
vim.api.nvim_create_autocmd("UiEnter", {
  desc = "Open Neotree automatically",
  group = "neotree",
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd "Neotree toggle"
    end
  end,
})
