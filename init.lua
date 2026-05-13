vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- In order to keep our folders clean, we add runtime folders to allow luasnip
-- to find our snippets lazily.
local path = debug.getinfo(1, 'S').source:gsub('^@', '')
local dir = vim.fn.fnamemodify(path, ':h')
vim.opt.rtp:prepend(dir .. '/snippets/')
vim.opt.rtp:prepend(dir .. '/snippets/vscode')

require('omnivium')
