return {
  "ofirgall/open.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ofirgall/open-jira.nvim",
  },
  config = function()
    require('open').setup {

      openers_config = {
        -- Override `jira` browser for example
        ['jira'] = {
          system_open = {
            cmd = '-browser',
          },
        },
      },
    }

  end
}

