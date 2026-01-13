return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({

			window = {
				mappings = {
					["Y"] = function(state)
						-- NeoTree is based on [NuiTree](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/tree)
						-- The node is based on [NuiNode](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/tree#nuitreenode)
						local node = state.tree:get_node()
						local filepath = node:get_id()
						local filename = node.name
						local modify = vim.fn.fnamemodify

						local results = {
							filepath,
							modify(filepath, ":."),
							modify(filepath, ":~"),
							filename,
							modify(filename, ":r"),
							modify(filename, ":e"),
						}

						-- absolute path to clipboard
						local i = vim.fn.inputlist({
							"Choose to copy to clipboard:",
							"1. Absolute path: " .. results[1],
							"2. Path relative to CWD: " .. results[2],
							"3. Filename: " .. results[4],
						})

						if i > 0 then
							local result = results[i]
							if not result then
								return print("Invalid choice: " .. i)
							end
							os.execute("echo " .. result .. "| wl-copy")
							vim.notify("Copied: " .. result)
						end
					end,
				},
			},
		})
		vim.keymap.set("n", ",,", ":Neotree filesystem reveal left<CR>", { desc = "Open filemanager in side panel" })
		vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})
	end,
}
