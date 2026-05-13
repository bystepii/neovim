return {
  {
    'luasnip',
    lazy = false,
    dep_of = { 'blink.cmp' },
    after = function(_)
      local ls = require('luasnip')
      local filetype_funcs = require('luasnip.extras.filetype_functions')
      ls.config.setup({
        history = true,
        updateevents = 'TextChanged,TextChangedI',
        delete_check_events = 'TextChanged,CursorMoved',
        store_selection_keys = '<Tab>',
        ext_opts = {
          [require('luasnip.util.types').choiceNode] = {
            active = {
              virt_text = { { '', '@character' } },
            },
          },
        },
        ft_func = filetype_funcs.from_cursor_pos,
        load_ft_func = filetype_funcs.extend_load_ft({
          nix = { 'markdown', 'lua', 'sh', 'python' },
          markdown = { 'nix', 'markdown', 'lua', 'sh', 'python' },
          just = { 'sh' },
        }),
      })

      require('luasnip.loaders.from_vscode').lazy_load()
      require('luasnip.loaders.from_lua').lazy_load()

      vim.keymap.set({ 'i', 's' }, '<c-k>', function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        end
      end, { silent = true })

      vim.keymap.set({ 'i', 's' }, '<c-j>', function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { silent = true })

      vim.keymap.set({ 'i', 's' }, '<c-l>', function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true })

      vim.keymap.set({ 'i', 's' }, '<C-f>', function()
        if ls.choice_active() then
          require('luasnip.extras.select_choice')()
        end
      end, { desc = 'Select luasnip choice' })
    end,
  },
  {
    'friendly-snippets',
    lazy = true,
    dep_of = { 'luasnip' },
  },
  {
    'vim-snippets',
    lazy = true,
    dep_of = { 'luasnip' },
  },
}