-- mini.surround configuration for Lua files
-- Adding support for [[  ]] as surround pairs
require('mini.surround').setup({
  custom_surroundings = {
    l = {
      input = { { '[[' }, { ']]' } },
      output = { { '[[' }, { ']]' } },
    },
  },
})