vim.opt.mouse = ""

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
require("lazy").setup({
	spec = {
		{
			"windwp/nvim-ts-autotag",
			dependencies = { "nvim-treesitter/nvim-treesitter" },
			config = function()
				require("nvim-ts-autotag").setup({
					opts = {
						enable_close = true, -- Auto close tags
						enable_rename = true, -- Auto rename pairs of tags
						enable_close_on_slash = false, -- Auto close on trailing </
					},
					-- Add htmldjango to filetypes
					filetypes = {
						"html",
						"javascript",
						"typescript",
						"svelte",
						"php",
						"htmldjango",
					},
				})
			end,
		},
		{ "Glench/Vim-Jinja2-Syntax" },
		{ "windwp/nvim-autopairs", event = "InsertEnter", config = true },
		-- LSP & Completion
		{ "neovim/nvim-lspconfig" },
		{ "tpope/vim-fugitive" },
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim", dependencies = { "neovim/nvim-lspconfig" } },
		{
			"hrsh7th/nvim-cmp",
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"saadparwaiz1/cmp_luasnip",
				"L3MON4D3/LuaSnip",
				"zbirenbaum/copilot-cmp",
			},
		},
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			config = function()
				require("mason-tool-installer").setup({
					ensure_installed = {
						"prettier",
						"stylua",
						-- add other formatters
					},
				})
			end,
		},
		{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

		-- UI Enhancements
		{ "EdenEast/nightfox.nvim", name = "nightfox", priority = 1000 },
		{ "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
		{ "folke/which-key.nvim", event = "VeryLazy" },
		{ "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

		-- Productivity
		{ "nvim-telescope/telescope.nvim", cmd = "Telescope" },
		{ "stevearc/conform.nvim" },
		{
			"theprimeagen/harpoon",
			branch = "harpoon2",
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
				require("harpoon"):setup()
			end,
			keys = {
				{
					"<leader>A",
					function()
						require("harpoon"):list():append()
					end,
					desc = "harpoon file",
				},
				{
					"<tab>",
					function()
						local harpoon = require("harpoon")
						harpoon.ui:toggle_quick_menu(harpoon:list())
					end,
					desc = "harpoon quick menu",
				},
				{
					"<leader>1",
					function()
						require("harpoon"):list():select(1)
					end,
					desc = "harpoon to file 1",
				},
				{
					"<leader>2",
					function()
						require("harpoon"):list():select(2)
					end,
					desc = "harpoon to file 2",
				},
				{
					"<leader>3",
					function()
						require("harpoon"):list():select(3)
					end,
					desc = "harpoon to file 3",
				},
				{
					"<leader>4",
					function()
						require("harpoon"):list():select(4)
					end,
					desc = "harpoon to file 4",
				},
				{
					"<leader>5",
					function()
						require("harpoon"):list():select(5)
					end,
					desc = "harpoon to file 5",
				},
			},
		},
		-- Icons & Misc
		{ "nvim-tree/nvim-web-devicons" },
	},
	install = { colorscheme = { "nightfox" } },
	checker = { enabled = true },
})

-- Configure nvim-tree
require("nvim-tree").setup({
	view = {
		side = "right", -- Open file tree on the right side
		width = 30, -- Set tree width
	},
	update_focused_file = {
		enable = true,
	},
	filters = {
		dotfiles = false, -- Show dotfiles
	},
})

-- LSP Configuration
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "pyright", "cssls", "gopls", "html", "intelephense", "svelte" },
	automatic_installation = true,
})

local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" }, -- LSP completions only
		{ name = "copilot", group_index = 2 }, -- Copilot (secondary source)
	}),
})

-- Formatting with Conform
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black", "isort" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		go = { "gofmt", "goimports" },
		rust = { "rustfmt" },
		json = { "prettier" },
		css = { "prettier" },
		gleam = { "gleam format" },
		erlang = { "erl_tidy" },
		exlixir = { "mix format" },
	},
	format_on_save = function(bufnr)
		if vim.b[bufnr].disable_autoformat then
			return
		end
		return {
			timeout_ms = 500,
			lsp_fallback = true,
		}
	end,
	-- Configure formatter options
	formatters = {
		prettier = {
			prepend_args = function(self, ctx)
				-- Set different tab widths based on filetype
				if ctx.filetype == "javascript" or ctx.filetype == "typescript" then
					return { "--tab-width", "2" }
					-- elseif ctx.filetype == "css" then
					-- 	return { "--tab-width", "4" }
				end
				return { "--tab-width", "4" } -- default
			end,
		},
	},
})

vim.keymap.set({ "n", "v" }, "<leader>lf", function()
	require("conform").format({ async = true })
end, { desc = "Format Buffer" })

require("lualine").setup({
	options = {
		theme = "auto",
		section_separators = "",
		component_separators = "|",
		globalstatus = true,
	},
})

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"lua",
		"python",
		"javascript",
		"typescript",
		"go",
		"rust",
		"json",
		"yaml",
		"html",
		"css",
		"bash",
		"php",
		"markdown",
		"markdown_inline",
		"svelte",
		"ruby",
		"htmldjango",
	}, -- Add more as needed
	highlight = { enable = true }, -- Enable syntax highlighting
	indent = {
		enable = true,
		disable = { "html" }, -- Add problematic filetypes
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<C-space>",
			node_incremental = "<C-space>",
			scope_incremental = "<C-s>",
			node_decremental = "<C-backspace>",
		},
	},
})

-- Telescope keymaps
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope.git_files, { desc = "Find Git Files" })
vim.keymap.set("n", "<leader>fa", telescope.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fo", telescope.lsp_document_symbols, { desc = "Show Symbols" })
vim.keymap.set("n", "<leader>fs", ":NvimTreeToggle<CR>", { desc = "Toggle File Tree" })
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "List Buffers" })
-- Telescop git commands
vim.keymap.set("n", "<leader>gc", telescope.git_commits, { desc = "List Commits" })
vim.keymap.set("n", "<leader>gb", telescope.git_branches, { desc = "List Branches" })
vim.keymap.set("n", "<leader>gs", telescope.git_status, { desc = "Show Status" })

-- Window navigation
vim.keymap.set("n", "<leader>bs", ":vsplit<CR>", { desc = "Split Left" })
vim.keymap.set("n", "<leader>bh", "<C-w>h", { desc = "Move Left" })
vim.keymap.set("n", "<leader>bl", "<C-w>l", { desc = "Move Right" })
vim.keymap.set("n", "<leader>bq", ":close<CR>", { desc = "Close Split" })

-- Buffer management
vim.keymap.set("n", "<leader>qq", function()
	local buf = vim.api.nvim_get_current_buf()
	vim.cmd("bprevious")
	vim.cmd("bdelete " .. buf)
end, { desc = "Close Current Buffer" })
vim.api.nvim_create_user_command("BufOnly", "bufdo bdelete|edit #|bdelete #", {})
vim.keymap.set("n", "<leader>qo", ":BufOnly<CR>", { desc = "Close All But Current Buffer" })

-- LSP keybindings
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "gr", telescope.lsp_references, { desc = "Go to References" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Information" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Actions" })
vim.keymap.set("n", "<leader>do", vim.diagnostic.open_float, { desc = "Show Diagnostics" })
vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

local function toggle_diagnostic()
	local config = vim.diagnostic.config()
	if config.virtual_text then
		vim.diagnostic.config({ virtual_text = false })
	else
		vim.diagnostic.config({ virtual_text = true })
	end
end

vim.keymap.set("n", "<leader>dt", toggle_diagnostic, { desc = "Toggle Diagnostics" })

-- Clipboard keybindings
vim.keymap.set("n", "<leader>s", function()
	local unnamed = vim.fn.getreg('"')
	local system = vim.fn.getreg("*")

	-- Swap the registers
	vim.fn.setreg('"', system)
	vim.fn.setreg("*", unnamed)

	print("Swapped unnamed register and system clipboard")
end, { desc = "Swap paste buffer with system clipboard" })
-- paste without losing the paste buffer
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwrite" })

-- Enable true color support
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd.colorscheme("nightfox")

-- Number toggle
vim.opt.number = true
local num_group = vim.api.nvim_create_augroup("numbertoggle", {})
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave" }, {
	group = num_group,
	callback = function()
		vim.opt.relativenumber = true
	end,
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter" }, {
	group = num_group,
	callback = function()
		vim.opt.relativenumber = false
	end,
})

-- Set up tab stops
vim.opt.tabstop = 2

-- Auto save on normal mode
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	callback = function()
		vim.cmd("silent! write")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "svelte",
	callback = function()
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
		vim.b.disable_autoformat = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "html",
	callback = function()
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
		vim.b.disable_autoformat = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "typescript",
	callback = function()
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
		vim.b.disable_autoformat = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "javascript",
	callback = function()
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
		vim.b.disable_autoformat = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "php",
	callback = function()
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "css",
	callback = function()
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
	end,
})

vim.filetype.add({
	extension = {
		njk = "htmldjango",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "htmldjango",
	callback = function()
		vim.bo.syntax = "htmldjango"
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
	end,
})
