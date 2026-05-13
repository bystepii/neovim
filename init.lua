local MP = ...

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local path = debug.getinfo(1, 'S').source:gsub('^@', '')
local dir = vim.fn.fnamemodify(path, ':h')
vim.opt.rtp:prepend(dir .. '/snippets/')
vim.opt.rtp:prepend(dir .. '/snippets/vscode')

require('omnivium')

# ============================================================================
# PLUGIN CATEGORIES — COMMENTED OUT BY DEFAULT
# Uncomment entries to enable lazy loading for that category.
# Each entry corresponds to a spec in module.nix.
# ============================================================================
nixInfo.lze.load({
  # { import = MP:relpath('omnivium/completion'), category = 'completion' },
  # { import = MP:relpath('omnivium/editing'),   category = 'editing' },
  # { import = MP:relpath('omnivium/format'),    category = 'format' },
  # { import = MP:relpath('omnivium/lsp'),       category = 'lsp',
  #   enabled = nixInfo(false, 'settings', 'devMode') },
  # { import = MP:relpath('omnivium/search'),    category = 'search' },
  # { import = MP:relpath('omnivium/ui'),         category = 'ui' },
  # { import = MP:relpath('omnivium/git'),       category = 'git',
  #   enabled = nixInfo(false, 'settings', 'devMode') },
  # { import = MP:relpath('omnivium/markdown'),  category = 'markdown' },
  # { import = MP:relpath('omnivium/ai'),         category = 'ai',
  #   enabled = nixInfo(false, 'settings', 'devMode') },
  # { import = MP:relpath('omnivium/debug'),      category = 'debug' },
})