local MP = ...
return {
  {
    'direnv-nvim',
    auto_enable = true,
    event = 'VimEnter',
    after = function(_)
      require('direnv').setup({
        autoload_direnv = true,
        statusline = {
          enabled = true,
          icon = '󱚟',
        },
        keybindings = {
          allow = '<Leader>da',
          deny = '<Leader>dd',
          reload = '<Leader>dr',
          edit = '<Leader>de',
        },
      })
    end,
  },
}
