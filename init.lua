local set = vim.opt
local keymap = vim.keymap
set.number = true
set.relativenumber = true
set.clipboard = unnamedplus

-- Highlight content after yank.
vim.api.nvim_create_autocmd({"TextYankPost"}, {
   pattern = { "*" },
    callback = function ()
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

-- End keymap define

-- https://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
vim.keymap.set("n", "j", [[ v:count ? 'j' : 'gj' ]], { noremap = true, expr = true })
vim.keymap.set("n", "k", [[ v:count ? 'k' : 'gk' ]], { noremap = true, expr = true })
