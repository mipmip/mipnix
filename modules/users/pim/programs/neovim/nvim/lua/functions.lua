function ReloadHomeManagerNeoVimConf()
  return function()
    print("Nix Home Manager: Rebuilding configuration..")
    local pid = vim.fn.getpid()
    local ok, result = pcall(vim.fn.writefile, {'kill -9 '.. tostring(pid)}, "/tmp/restartVim.sh")
    local job = vim.fn.jobstart(
      'cd /etc/nixos && ./RUNME.sh up_home',
      {
        cwd = '/etc/nixos',
        on_exit = function()
          print("Nix Home Manager: Configuration rebuild finished")
          if ok then
            --vim.fn.system('kill -9 '.. tostring(pid))
          else
            print(result)
          end
        end,
        on_stdout = function()
        end,
        on_stderr = function()
        end
      }
    )
  end
end

-- Resizes
vim.api.nvim_create_user_command("Vr", function(opts)
    local usage = "Usage: [VirticalResize] :Vr {number (%)}"
    if not opts.args or not string.len(opts.args) == 2 then
        print(usage)
        return
    end
    vim.cmd(":vertical resize " .. vim.opt.columns:get() * (opts.args / 100.0))
end, { nargs = "*" })

vim.api.nvim_create_user_command("Hr", function(opts)
    local usage = "Usage: [HorizontalResize] :Hr {number (%)}"
    if not opts.args or not string.len(opts.args) == 2 then
        print(usage)
        return
    end
    vim.cmd(
        ":resize "
            .. (
                (vim.opt.lines:get() - vim.opt.cmdheight:get())
                * (opts.args / 100.0)
            )
    )
end, { nargs = "*" })

--vim.api.nvim_create_user_command('ReloadHomeManagerNeoVimConf', ReloadHomeManagerNeoVimConf, {})


--function ToggleSpell(scope)
--  return function ()
--    scope.spell = not scope.spell
--    vim.cmd("redraw")
--    print("spell is " .. tostring(scope.spell))
--  end
--end


