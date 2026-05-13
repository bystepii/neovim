vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local path = debug.getinfo(1, 'S').source:gsub('^@', '')
local dir = vim.fn.fnamemodify(path, ':h')
vim.opt.rtp:prepend(dir .. '/snippets/')
vim.opt.rtp:prepend(dir .. '/snippets/vscode')

require('omnivium')
