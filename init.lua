local set = vim.opt
local keymap = vim.keymap
local opts = { noremap = true, silent = true }

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
-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

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

