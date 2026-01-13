local commander = require("commander")

-- prefil edit window with common scenarios to avoid repeating query and submit immediately
local prefill_edit_window = function(request)
  require('avante.api').edit()
  local code_bufnr = vim.api.nvim_get_current_buf()
  local code_winid = vim.api.nvim_get_current_win()
  if code_bufnr == nil or code_winid == nil then
    return
  end
  vim.api.nvim_buf_set_lines(code_bufnr, 0, -1, false, { request })
  -- Optionally set the cursor position to the end of the input
  vim.api.nvim_win_set_cursor(code_winid, { 1, #request + 1 })
  -- Simulate Ctrl+S keypress to submit
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-s>', true, true, true), 'v', true)
end

local avante_translate_en = 'Translate this into English, but keep any formatting and code blocks inside intact'
local avante_translate_nl = 'Translate this into Dutch, but keep any formatting and code blocks inside intact'

commander.add({

  {
    desc = "Translate text to English(chat)",
    cmd = function()
      require('avante.api').ask { question = avante_translate_en, ask = false }
    end,
    keys = { {"n"}, "<leader>te" },
    cat = "avante",
  },

  {
    desc = "Translate text to English(edit)",
    cmd = function()
      prefill_edit_window(avante_translate_en)
    end,
    keys = { {"v"}, "<leader>te" },
    cat = "avante",
  },

  {
    desc = "Translate text to Dutch(ask)",
    cmd = function()
      require('avante.api').ask { question = avante_translate_nl, ask = false  }
    end,
    keys = { {"n"}, "<leader>tn" },
    cat = "avante",
  },

  {
    desc = "Translate text to Dutch(edit)",
    cmd = function()
      prefill_edit_window(avante_translate_nl)
    end,
    keys = { {"v"}, "<leader>tn" },
    cat = "avante",
  },

})



