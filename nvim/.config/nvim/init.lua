--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

Migrated from lazy.nvim to vim.pack (Neovim's built-in package manager).

Plugin management:
  :lua vim.pack.update()       -- update all plugins
  :lua vim.pack.update({"x"})  -- update specific plugin
  :lua vim.pack.get()          -- list installed plugins
  :lua vim.pack.del({"x"})     -- remove a plugin

Lockfile lives at $XDG_CONFIG_HOME/nvim/nvim-pack-lock.json
--]]

-- Set <space> as the leader key
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.o`

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = false
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selected lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selected lines up" })

-- [[ Basic Autocommands ]]

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- [[ Install plugins via vim.pack ]]
--
-- vim.pack handles git cloning, loading, and updating.
-- On first run, you'll be prompted to confirm installation.

-- Build hooks for plugins that need compilation after install/update
vim.api.nvim_create_autocmd("User", {
	pattern = "PackChanged",
	callback = function(ev)
		if ev.data.kind == "delete" then
			return
		end
		local name = ev.data.spec.name
		local path = ev.data.path
		if name == "telescope-fzf-native.nvim" then
			vim.fn.system({ "make", "-C", path })
		elseif name == "LuaSnip" and vim.fn.executable("make") == 1 then
			vim.fn.system({ "make", "install_jsregexp", "-C", path })
		elseif name == "nvim-treesitter" then
			vim.cmd("TSUpdate")
		end
	end,
})

local plugins = {
	-- Core utilities
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/DaikyXendo/nvim-material-icon",
	"https://github.com/folke/snacks.nvim",

	-- Colorschemes
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	"https://github.com/rebelot/kanagawa.nvim",

	-- UI
	"https://github.com/NMAC427/guess-indent.nvim",
	"https://github.com/goolord/alpha-nvim",
	"https://github.com/echasnovski/mini.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/j-hui/fidget.nvim",
	"https://github.com/pteroctopus/faster.nvim",
	"https://github.com/3rd/image.nvim",

	-- File navigation
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/malewicz1337/oil-git.nvim",

	-- Telescope
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-telescope/telescope-ui-select.nvim",

	-- Git
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/f-person/git-blame.nvim",
	"https://github.com/kdheepak/lazygit.nvim",
	"https://github.com/sindrets/diffview.nvim",

	-- AI
	"https://github.com/github/copilot.vim",
	"https://github.com/coder/claudecode.nvim",

	-- LSP
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mason-org/mason-lspconfig.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	"https://github.com/folke/lazydev.nvim",

	-- Completion & Snippets
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range(">=1.0.0 <2.0.0") },
	{ src = "https://github.com/L3MON4D3/LuaSnip", version = vim.version.range(">=2.0.0 <3.0.0") },
	"https://github.com/rafamadriz/friendly-snippets",

	-- Formatting
	"https://github.com/stevearc/conform.nvim",

	-- Treesitter
	"https://github.com/nvim-treesitter/nvim-treesitter",
}

-- Conditionally add telescope-fzf-native if make is available
if vim.fn.executable("make") == 1 then
	table.insert(plugins, "https://github.com/nvim-telescope/telescope-fzf-native.nvim")
end

vim.pack.add(plugins, { load = true })

-- [[ Plugin Configuration ]]
-- All plugins are now loaded; configure them in dependency order.

-- Colorscheme (first, for immediate visual effect)
vim.cmd.colorscheme("kanagawa-wave")

-- guess-indent
require("guess-indent").setup({})

-- alpha-nvim (dashboard)
do
	local alpha = require("alpha")
	local theta = require("alpha.themes.theta")
	local headers = require("custom.dashboard-headers")
	local config = theta.config
	config.layout[2] = {
		type = "text",
		val = headers.random(),
		opts = { position = "center", hl = "Normal" },
	}
	alpha.setup(config)
end

-- nvim-material-icon (drop-in replacement for nvim-web-devicons)
require("nvim-web-devicons").setup({})

-- oil.nvim
require("oil").setup({
	view_options = {
		show_hidden = true,
		is_always_hidden = function(name, _)
			return vim.tbl_contains({ ".git", "node_modules", ".DS_Store" }, name)
		end,
	},
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- oil-git.nvim
require("oil-git").setup({
	debounce_ms = 50,
	ignore_gitsigns_update = true,
})

-- gitsigns
require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
})

-- claudecode.nvim
require("claudecode").setup({
	terminal = { provider = "none" },
})
vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
vim.keymap.set("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
vim.keymap.set("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" })
vim.keymap.set("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Select Model" })
vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add Current Buffer" })
vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept Diff" })
vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny Diff" })

-- which-key
require("which-key").setup({
	delay = 0,
	icons = {
		mappings = vim.g.have_nerd_font,
		keys = vim.g.have_nerd_font and {} or {
			Up = "<Up> ",
			Down = "<Down> ",
			Left = "<Left> ",
			Right = "<Right> ",
			C = "<C-…> ",
			M = "<M-…> ",
			D = "<D-…> ",
			S = "<S-…> ",
			CR = "<CR> ",
			Esc = "<Esc> ",
			ScrollWheelDown = "<ScrollWheelDown> ",
			ScrollWheelUp = "<ScrollWheelUp> ",
			NL = "<NL> ",
			BS = "<BS> ",
			Space = "<Space> ",
			Tab = "<Tab> ",
			F1 = "<F1>",
			F2 = "<F2>",
			F3 = "<F3>",
			F4 = "<F4>",
			F5 = "<F5>",
			F6 = "<F6>",
			F7 = "<F7>",
			F8 = "<F8>",
			F9 = "<F9>",
			F10 = "<F10>",
			F11 = "<F11>",
			F12 = "<F12>",
		},
	},
	spec = {
		{ "<leader>a", group = "[A]I Claude" },
		{ "<leader>g", group = "[G]it" },
		{ "<leader>s", group = "[S]earch" },
		{ "<leader>t", group = "[T]oggle" },
		{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
		{ "<leader>y", group = "[Y]ank with context" },
	},
})

-- telescope
do
	require("telescope").setup({
		extensions = {
			["ui-select"] = {
				require("telescope.themes").get_dropdown(),
			},
		},
	})

	pcall(require("telescope").load_extension, "fzf")
	pcall(require("telescope").load_extension, "ui-select")

	local builtin = require("telescope.builtin")
	vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
	vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
	vim.keymap.set("n", "<leader>sf", function()
		builtin.find_files({ hidden = true })
	end, { desc = "[S]earch [F]iles" })
	vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
	vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
	vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
	vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
	vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
	vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
	vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

	vim.keymap.set("n", "<leader>/", function()
		builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			winblend = 10,
			previewer = false,
		}))
	end, { desc = "[/] Fuzzily search in current buffer" })

	vim.keymap.set("n", "<leader>s/", function()
		builtin.live_grep({
			grep_open_files = true,
			prompt_title = "Live Grep in Open Files",
		})
	end, { desc = "[S]earch [/] in Open Files" })

	vim.keymap.set("n", "<leader>sn", function()
		builtin.find_files({ cwd = vim.fn.stdpath("config") })
	end, { desc = "[S]earch [N]eovim files" })
end

-- lazydev (Lua LSP config for Neovim — unrelated to lazy.nvim)
require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})

-- fidget (LSP progress notifications)
require("fidget").setup({})

-- mason (before LSP config)
require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = {},
	automatic_installation = false,
	automatic_enable = false,
})
require("mason-tool-installer").setup({
	ensure_installed = {
		"gopls",
		"ts_ls",
		"lua_ls",
		"stylua",
		"goimports",
		"gofumpt",
	},
})

-- LuaSnip + friendly-snippets (before blink.cmp)
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/snippets" } })
require("luasnip").filetype_extend("ruby", { "rails" })
require("luasnip").filetype_extend("eruby", { "ejs" })

-- blink.cmp (completion — before LSP config since LSP uses its capabilities)
require("blink.cmp").setup({
	keymap = { preset = "enter" },
	appearance = { nerd_font_variant = "mono" },
	completion = {
		documentation = { auto_show = false, auto_show_delay_ms = 500 },
	},
	sources = {
		default = { "lsp", "path", "snippets", "lazydev" },
		providers = {
			lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
		},
	},
	snippets = { preset = "luasnip" },
	fuzzy = { implementation = "lua" },
	signature = { enabled = true },
})

-- LSP Configuration
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
		map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
		map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
		map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
		map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
		map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
		map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if
			client
			and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
		then
			local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})
			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
				end,
			})
		end

		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[T]oggle Inlay [H]ints")
		end
	end,
})

-- Diagnostic Config
vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = true },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = vim.g.have_nerd_font and {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	} or {},
	virtual_text = {
		source = true,
		spacing = 2,
		format = function(diagnostic)
			local diagnostic_message = {
				[vim.diagnostic.severity.ERROR] = diagnostic.message,
				[vim.diagnostic.severity.WARN] = diagnostic.message,
				[vim.diagnostic.severity.INFO] = diagnostic.message,
				[vim.diagnostic.severity.HINT] = diagnostic.message,
			}
			return diagnostic_message[diagnostic.severity]
		end,
	},
})

-- LSP server configurations
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.lsp.config("gopls", {
	settings = {
		gopls = {
			analyses = { unusedparams = true },
			staticcheck = true,
			gofumpt = true,
		},
	},
})

vim.lsp.config("ts_ls", {})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			completion = { callSnippet = "Replace" },
			diagnostics = { globals = { "vim" } },
		},
	},
})

vim.lsp.config("ruby_lsp", {
	cmd = { "/Users/rileyjhardy/.asdf/shims/ruby-lsp" },
	filetypes = { "ruby", "eruby" },
	root_markers = { "Gemfile", ".git" },
	init_options = {
		formatter = "auto",
		linters = { "rubocop" },
	},
	reuse_client = function(client, config)
		return client.root_dir == config.root_dir
	end,
})

vim.lsp.enable({ "gopls", "ts_ls", "lua_ls", "ruby_lsp" })

-- conform.nvim (formatting)
require("conform").setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		local disable_filetypes = { c = true, cpp = true }
		if disable_filetypes[vim.bo[bufnr].filetype] then
			return nil
		else
			return { timeout_ms = 500, lsp_format = "fallback" }
		end
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "goimports", "gofumpt" },
	},
})
vim.keymap.set("", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })

-- git-blame
require("gitblame").setup({
	enabled = true,
	message_template = " <summary> • <date> • <author> • <<sha>>",
	date_format = "%r",
	virtual_text_column = 1,
})

-- image.nvim (Kitty terminal image preview)
require("image").setup({
	backend = "kitty",
	processor = "magick_cli",
	integrations = {
		markdown = {
			enabled = false, -- disabled until image.nvim handles vim.treesitter.get_parser() returning nil in Neovim 0.12
			clear_in_insert_mode = false,
			download_remote_images = true,
			only_render_image_at_cursor = false,
			only_render_image_at_cursor_mode = "popup",
		},
	},
	max_height_window_percentage = 50,
	hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
})

-- lazygit
vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

-- diffview
do
	local is_git_ignored = function(filepath)
		vim.fn.system("git check-ignore -q " .. vim.fn.shellescape(filepath))
		return vim.v.shell_error == 0
	end

	local update_left_pane = function()
		pcall(function()
			local lib = require("diffview.lib")
			local view = lib.get_current_view()
			if view then
				view:update_files()
			end
		end)
	end

	require("custom.directory-watcher").registerOnChangeHandler("diffview", function(filepath, events)
		local is_in_dot_git_dir = filepath:match("/%.git/") or filepath:match("^%.git/")
		if is_in_dot_git_dir or not is_git_ignored(filepath) then
			update_left_pane()
		end
	end)

	vim.api.nvim_create_autocmd("FocusGained", { callback = update_left_pane })

	vim.api.nvim_create_autocmd("User", {
		pattern = "DiffviewViewLeave",
		callback = function()
			vim.cmd(":DiffviewClose")
		end,
	})

	require("diffview").setup({
		default_args = {
			DiffviewOpen = { "--imply-local" },
		},
		keymaps = {
			view = {
				{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			},
			file_panel = {
				{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			},
			file_history_panel = {
				{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			},
		},
	})
end
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "[G]it [D]iffview" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "[G]it File [H]istory" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "[G]it Branch [H]istory" })
vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<cr>", { desc = "[G]it Diffview [C]lose" })

-- mini.nvim
require("mini.ai").setup({ n_lines = 500 })
require("mini.surround").setup()
do
	local statusline = require("mini.statusline")
	statusline.setup({ use_icons = vim.g.have_nerd_font })
	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_location = function()
		return "%2l:%-2v"
	end
end

-- nvim-treesitter
require("nvim-treesitter.config").setup({
	ensure_installed = {
		"bash",
		"c",
		"css",
		"diff",
		"go",
		"gomod",
		"gosum",
		"gowork",
		"html",
		"lua",
		"luadoc",
		"markdown",
		"markdown_inline",
		"query",
		"vim",
		"vimdoc",
		"ruby",
	},
	auto_install = true,
	highlight = { enable = true },
	indent = { enable = true, disable = { "ruby" } },
})

-- ============================================================================
-- Claude Code Integration: Directory Watcher, Hot-reload, and Enhanced Yank
-- Based on: https://xata.io/blog/configuring-neovim-coding-agents
-- ============================================================================

local function setup_directory_watcher()
	local result = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")
	if vim.v.shell_error == 0 and #result > 0 then
		local git_root = result[1]
		require("custom.directory-watcher").setup({ path = git_root })
	end
end

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
	group = vim.api.nvim_create_augroup("DirectoryWatcherSetup", { clear = true }),
	callback = function()
		vim.defer_fn(setup_directory_watcher, 100)
	end,
})

require("custom.hotreload").setup()

-- vim: ts=2 sts=2 sw=2 et
