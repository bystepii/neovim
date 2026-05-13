-- mini.surround configuration for Lua files
-- Adding support for [[  ]] as surround pairs
-- require('mini.surround').setup({
vim.b.minisurround_config = {
  custom_surroundings = {
    l = {
      input = { { '[[' }, { ']]' } },
      output = { { '[[' }, { ']]' } },
    },
  },
}---)
