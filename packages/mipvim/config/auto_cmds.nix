{
  autoGroups = {
    highlight_yank = { };
    vim_enter = { };
    indentscope = { };
    restore_cursor = { };
    md_filetype = { };
    auto_reload = { };
  };

  autoCmd = [
    {
      group = "highlight_yank";
      event = [ "TextYankPost" ];
      pattern = "*";
      callback = {
        __raw = ''
          function()
            vim.highlight.on_yank()
          end
        '';
      };
    }
    {
      group = "vim_enter";
      event = [ "VimEnter" ];
      pattern = "*";
      callback = {
        __raw = ''
          function()
            if vim.fn.argc() == 0 then
              vim.cmd "Neotree toggle"
            end
          end
        '';
      };
    }
    {
      group = "md_filetype";
      event = [ "FileType" ];
      pattern = [
        "markdown"
      ];
      callback = {
        __raw = ''
          function(args)
            vim.diagnostic.enable(false)
          end
        '';
      };
    }
    {
      group = "indentscope";
      event = [ "FileType" ];
      pattern = [
        "help"
        "neo-tree"
        "Trouble"
        "trouble"
        "notify"
      ];
      callback = {
        __raw = ''
          function()
            vim.b.miniindentscope_disable = true
          end
        '';
      };
    }
    ## Auto-reload buffers and neo-tree git status when returning to nvim or
    ## leaving a terminal — catches external edits / `git checkout` made while
    ## nvim was focused but idle (the case the libuv watcher misses).
    {
      group = "auto_reload";
      event = [ "FocusGained" "BufEnter" "TermClose" "TermLeave" ];
      pattern = "*";
      callback = {
        __raw = ''
          function()
            if vim.o.buftype ~= "c" then
              vim.cmd("checktime")
            end
            local ok, mgr = pcall(require, "neo-tree.sources.manager")
            if ok then
              pcall(mgr.refresh, "git_status")
            end
          end
        '';
      };
    }
    ## from NVChad https://nvchad.com/docs/recipes (this autocmd will restore the cursor position when opening a file)
    {
      group = "restore_cursor";
      event = [ "BufReadPost" ];
      pattern = "*";
      callback = {
        __raw = ''
          function()
            if
              vim.fn.line "'\"" > 1
              and vim.fn.line "'\"" <= vim.fn.line "$"
              and vim.bo.filetype ~= "commit"
              and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
            then
              vim.cmd "normal! g`\""
            end
          end
        '';
      };
    }
  ];
}
