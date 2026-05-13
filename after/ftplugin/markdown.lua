-- mini.surround and mini.ai configuration for markdown files
-- Support for [[link]] and {{citation}} style surroundings
require('mini.surround').setup({
  custom_surroundings = {
    l = {
      input = { { '[[' }, { ']]' } },
      output = { { '[[' }, { ']]' } },
    },
    c = {
      input = { { '{{' }, { '}}' } },
      output = { { '{{' }, { '}}' } },
    },
  },
})

require('mini.ai').setup({
  custom_textobjects = {
    c = require('mini.ai').gen_spec.treesitter({
      a = '@comment.inner',
      i = '@comment.outer',
    }),
  },
})