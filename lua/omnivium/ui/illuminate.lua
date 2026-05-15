return {
  {
    -- FIXME: this isn't working
    'vim-illuminate',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('illuminate').configure({})
    end,
  },
}
