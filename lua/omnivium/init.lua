local MP = ...

string.relpath = function(str, sub, n)
  local result = {}
  n = type(sub) == 'string' and n or sub
  if type(n) == 'number' and n > 0 then
    for match in (str .. '.'):gmatch('(.-)%.') do
      table.insert(result, match)
    end
    while n > 0 do
      table.remove(result)
      n = n - 1
    end
  else
    table.insert(result, str)
  end
  if type(sub) == 'string' then
    table.insert(result, sub)
  end
  return #result == 1 and result[1] or table.concat(result, '.')
end

local path = debug.getinfo(1, 'S').source:gsub('^@', '')
local dir = vim.fn.fnamemodify(path, ':h:h:h')
vim.opt.rtp:prepend(dir .. '/snippets/')
vim.opt.rtp:prepend(dir .. '/snippets/vscode')
vim.opt.packpath:prepend(dir)
local after_dir = dir .. '/after'
if vim.fn.isdirectory(after_dir) == 1 then
  vim.opt.rtp:append(after_dir)
end

vim.loader.enable()

require(MP:relpath('nixinfo'))

-- ===========================================================================
-- PLUGIN CATEGORIES — COMMENTED OUT BY DEFAULT
-- Uncomment entries to enable lazy loading for that category.
-- Each entry corresponds to a spec in module.nix.
-- ===========================================================================
nixInfo.lze.load({
  -- { import = MP:relpath('completion'), category = 'completion' },
  -- { import = MP:relpath('editing'),    category = 'editing' },
  -- { import = MP:relpath('format'),     category = 'format' },
  -- { import = MP:relpath('lsp'),        category = 'lsp',
  --   enabled = nixInfo(false, 'settings', 'devMode') },
  -- { import = MP:relpath('search'),    category = 'search' },
  { import = MP:relpath('ui'),        category = 'ui' },
  -- { import = MP:relpath('git'),        category = 'git',
  --   enabled = nixInfo(false, 'settings', 'devMode') },
  -- { import = MP:relpath('markdown'),  category = 'markdown' },
  -- { import = MP:relpath('ai'),        category = 'ai',
  --   enabled = nixInfo(false, 'settings', 'devMode') },
  -- { import = MP:relpath('debug'),     category = 'debug' },
})
