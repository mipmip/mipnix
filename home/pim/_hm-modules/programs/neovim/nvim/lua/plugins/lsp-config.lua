return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      
      -- Useful status updates for LSP
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      -- Set up Mason before anything else
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "tsserver",
          "rust_analyzer",
        },
        automatic_installation = true,
      })
      
      -- Additional tools that don't have an associated LSP
      require("mason-tool-installer").setup({
        ensure_installed = {
          "stylua", -- Lua formatter
          "prettier", -- JavaScript/TypeScript formatter
          "black", -- Python formatter
          "isort", -- Python import sorter
          "eslint_d", -- JavaScript/TypeScript linter
        },
      })

      -- Configure diagnostic display
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
        },
      })

      -- Add borders to hover and signature help
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = "rounded",
        }
      )
      
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
          border = "rounded",
        }
      )

      -- Define on_attach function to set keymaps after LSP attaches to buffer
      local on_attach = function(client, bufnr)
        -- Helper function for easier keymap setting
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- LSP keymaps
        map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
        map("n", "gr", vim.lsp.buf.references, "Go to References")
        map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
        map("n", "gI", vim.lsp.buf.implementation, "Go to Implementation")
        map("n", "gt", vim.lsp.buf.type_definition, "Go to Type Definition")
        map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
        map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
        map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format Document")
        
        -- Diagnostics
        map("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
        map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
        map("n", "<leader>e", vim.diagnostic.open_float, "Show Diagnostic")
        map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics in Location List")

        -- Workspace
        map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
        map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
        map("n", "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, "List Workspace Folders")
      end

      -- Set up LSP servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Configure each server
      local lspconfig = require("lspconfig")

      -- Lua
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.stdpath("config") .. "/lua"] = true,
              },
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })

      -- TypeScript/JavaScript
      lspconfig.tsserver.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })

      -- Python
      lspconfig.pyright.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      -- Rust
      lspconfig.rust_analyzer.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
            inlayHints = {
              closingBraceHints = true,
              parameterHints = true,
              typeHints = true,
            },
          },
        },
      })

      -- Set up additional LSP servers with default configuration
      local servers = {
        "bashls",        -- Bash
        "clangd",        -- C/C++
        "gopls",         -- Go
        "html",          -- HTML
        "cssls",         -- CSS
        "jsonls",        -- JSON
        "yamlls",        -- YAML
        "marksman",      -- Markdown
        "dockerls",      -- Docker
        "terraformls",   -- Terraform
      }

      for _, server in ipairs(servers) do
        lspconfig[server].setup({
          on_attach = on_attach,
          capabilities = capabilities,
        })
      end
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      -- Load snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = function(entry, vim_item)
            -- Set a name for each source
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })
    end,
  },
}
