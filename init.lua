local set = vim.opt
local keymap = vim.keymap

-- Set number & line
set.number = true
set.relativenumber = true
set.clipboard = unnamedplus

-- Set Indent
set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4
set.expandtab = true
set.autoindent = true
set.smartindent = true
set.number = true
set.cursorline = true

-- Highlight content after yank.
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
    pattern = { "*" },
    callback = function()
        vim.highlight.on_yank({ timeout = 160 })
    end,
})
-- End highlight content after yank.

-- Keybindings
vim.g.mapleader = " "
local opts = { noremap = true, silent = true }

-- Split window
keymap.set("n", "ss", ":vsplit<Return>", opts)
keymap.set("n", "sv", ":split<Return>", opts)
keymap.set("n", "<Leader>s", ":vsplit<Return>", opts)
keymap.set("n", "<Leader>v", ":split<Return>", opts)

-- Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sl", "<C-w>l")

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- Jump file
keymap.set("n", "<Leader>[", "<C-o>", opts)
keymap.set("n", "<Leader>]", "<C-i>", opts)

-- End keymap define

-- https://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
vim.keymap.set("n", "j", [[ v:count ? 'j' : 'gj' ]], { noremap = true, expr = true })
vim.keymap.set("n", "k", [[ v:count ? 'k' : 'gk' ]], { noremap = true, expr = true })

-- Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath
    })
end

set.rtp:prepend(lazypath)

require('lazy').setup({
    -- theme
    {
        "RRethy/nvim-base16",
        lazy = true,
    },
    -- 语法解析、高亮
    {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate"
    },
    -- UI 弹窗提示
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {},
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify"
        }
    },
    -- 记住上次编辑状态
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = {}
    },
    -- 提示 Keybinding
    {
        "folke/which-key.nvim",
        opts = {}
    },
    -- 安装 Telescope https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#getting-started
    -- 前置需要安装 ripgrep https://github.com/BurntSushi/ripgrep?tab=readme-ov-file#installation
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = {
            "nvim-lua/plenary.nvim"
        },
        cmd = "Telescope",
        keys = {
            { "<leader>p",  ":Telescope find_files<CR>", desc = "Find files" },
            { "<leader>q",  ":Telescope oldfiles<CR>",   desc = "Old files" },
            { "<leader>P",  ":Telescope live_grep<CR>",  desc = "Grep files" },
            { "<leader>rs", ":Telescope resume<CR>",     desc = "Resume" },
        }
    },
    -- LSP
    -- LSP Mason https://github.com/williamboman/mason.nvim
    -- After install mason, we can use :MasonInstall lsp,ex: pyright
    {
        "williamboman/mason.nvim",
        event = "VeryLazy",
    },
    -- LSP config https://github.com/neovim/nvim-lspconfig
    {
        "neovim/nvim-lspconfig",
        event = "VeryLazy",
        dependencies = {
            -- Mason lspconfig https://github.com/williamboman/mason-lspconfig.nvim
            "williamboman/mason-lspconfig.nvim",
        },
    },

})
-- End lazy.nvim

-- Themecolor
vim.cmd.colorscheme("base16-tender")
-- End themecolor

-- UI
-- End UI

-- LSP setup language servers.
require("mason").setup()
require("mason-lspconfig").setup()

-- 突然加速，没看懂1
require("lspconfig").lua_ls.setup({
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim", "hs" },
            },
            workspace = {
                checkThirdParty = false,
                -- Make the server aware of Neovim runtime files
                library = {
                    -- vim.api.nvim_get_runtime_file("", true),
                    "/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/",
                    vim.fn.expand("~/lualib/share/lua/5.4"),
                    vim.fn.expand("~/lualib/lib/luarocks/rocks-5.4"),
                    "/opt/homebrew/opt/openresty/lualib",
                },
            },
            completion = {
                callSnippet = "Replace",
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
})

-- 突然加速 没看懂2
-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<Leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<Leader>f', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})
-- End LSP setup language servers.
