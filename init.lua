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
    -- {
    -- "RRethy/nvim-base16",
    -- lazy = true,
    -- },
    {
        "craftzdog/solarized-osaka.nvim",
        lazy = true,
        priority = 1000,
        opts = function()
            return {
                transparent = true
            }
        end
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
    -- 代码补全 Config auto complete https://github.com/hrsh7th/nvim-cmp
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            'neovim/nvim-lspconfig',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/nvim-cmp',
            'L3MON4D3/luaSnip',
        },
        event = "VeryLazy",
    },
    -- Neovim 配置文档补全 neodev: https://github.com/folke/neodev.nvim
    {
        "folke/neodev.nvim",
        event = "VeryLazy",
    },
    -- 自动格式化 nullls: https://github.com/jose-elias-alvarez/null-ls.nvim
    {
        "jose-elias-alvarez/null-ls.nvim",
        event = "VeryLazy",
        config = function()
            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.black,
                },
                on_attach = function(client, bufnr)
                    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
                    if client.supports_method("textDocument/formatting") then
                        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            group = augroup,
                            buffer = bufnr,
                            callback = function()
                                -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                                -- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
                                -- vim.lsp.buf.formatting_sync()
                                vim.lsp.buf.format({ async = false })
                            end,
                        })
                    end
                end,
            })
        end
    },
    -- Git 插件: https://github.com/tpope/vim-fugitive
    {
        "tpope/vim-fugitive",
        event = "VeryLazy",
        cmd = "Git",
        config = function()
            -- Convert
            vim.cmd.cnoreabbrev([[git Git]])
            vim.cmd.cnoreabbrev([[gp Git push]])
        end,
    },
    -- 文件内展示 GIT 变动的插件 https://github.com/lewis6991/gitsigns.nvim
    {
        "lewis6991/gitsigns.nvim",
        event = "VeryLazy",
        config = function()
            require('gitsigns').setup()
        end,
    },
    -- Share 代码时，不复制行号 https://github.com/tpope/vim-rhubarb
    {
        "tpope/vim-rhubarb",
        event = "VeryLazy",
    },
    -- 标记git 合并时冲突的部分: https://github.com/rhysd/conflict-marker.vim
    {
        "rhysd/conflict-marker.vim",
        event = "VeryLazy",
    },

})
-- End lazy.nvim

-- Themecolor
-- vim.cmd.colorscheme("base16-tender")
vim.cmd.colorscheme("solarized-osaka")
-- End themecolor

-- UI
-- End UI

-- LSP setup language servers.
require("mason").setup()
require("mason-lspconfig").setup()

require("neodev").setup({})

-- 突然加速，没看懂1
-- Set up lspconfig.

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("lspconfig").lua_ls.setup({
    capabilities = capabilities,
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

-- Cmp Config
local cmp = require('cmp')
local luasnip = require('luasnip')

local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
                -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
                -- that way you will only jump inside the snippet region
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
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

        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-c>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        -- { name = 'vsnip' }, -- For vsnip users.
        { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
    }, {
        { name = 'buffer' },
    })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    }, {
        { name = 'buffer' },
    })
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

-- End cmp Config

-- Setup language lsp
require("lspconfig").html.setup({
    capabilities = capabilities,
})
-- End setup language lsp



-- Example
