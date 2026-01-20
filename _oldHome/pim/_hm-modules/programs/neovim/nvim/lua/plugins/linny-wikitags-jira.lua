return {
  "linden-project/linny-wikitag-jira",
  dependencies = {
    "linden-project/linny.vim",
  },

  enabled = function()

    local filename = os.getenv( "HOME" ) .. "/.i-am-second-brain"
    local f=io.open( filename ,"r")

    if f~=nil then
      io.close(f)
      return true
    else
      return false
    end
  end,


  config = function()
  -- Uncomment if your Jira instance has it's own subdomain...
  --   be sure to add a trailing slash
    vim.g.linny_wikitag_jira_baseurl = "https://technative.atlassian.net/browse/"
  end
}
