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