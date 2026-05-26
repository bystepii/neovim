return {
  {
    'fidget.nvim',
    after = function(_)
      require('fidget').setup({
        progress = {
          display = {
            done_icon = '✓',
            done_style = 'Constant',
            progress_icon = { pattern = 'dots', period = 1 },
            progress_style = 'WarningMsg',
            group_style = 'Title',
            icon_style = 'Question',
            format_annote = function(msg)
              return msg.title
            end,
            format_message = function(msg)
              if msg.percentage then
                return string.format('%s%%', msg.percentage)
              end
              return msg.message or ''
            end,
          },
        },
        notification = {
          filter = vim.log.levels.INFO,
          history_size = 128,
          override_vim_notify = false,
          configs = {
            default = require('fidget.notification').default_config,
          },
        },
      })
    end,
  },
}
