-- mini.surround and mini.ai configuration for Nix files
-- Support for '' strings and ${} expansions
require('mini.surround').setup({
  custom_surroundings = {
    s = {
      input = { { "''" }, { "''" } },
      output = { { "''" }, { "''" } },
    },
    d = {
      input = { { '${' }, { '}' } },
      output = { { '${' }, { '}' } },
    },
  },
})

require('mini.ai').setup({
  custom_textobjects = {
    e = require('mini.ai').gen_spec.treesitter({
      a = '@embedded.i',
      i = '@embedded.inner',
    }),
  },
})