return {
  {
    'copilot.lua',
    event = 'InsertEnter',
    cmd = { 'Copilot' },
    after = function()
      local cp = '<leader>ap'

      require('copilot').setup({
        panel = {
          enabled = true,
        },
        suggestion = {
          enabled = false,
          auto_trigger = false,
          keymap = {
            accept = false,
            accept_word = false,
            accept_line = false,
            next = false,
            prev = false,
            dismiss = false,
          },
        },
        nes = {
          enabled = true,
          keymap = {
            accept_and_goto = '<leader>aN',
            accept = '<leader>an',
            dismiss = '<leader>ad',
          },
        },
      })

      -- stylua: ignore start
      -- Copilot management
      vim.keymap.set('n', cp .. 'e', '<cmd>Copilot enable<CR>', { desc = 'Copilot enable' })
      vim.keymap.set('n', cp .. 'd', '<cmd>Copilot disable<CR>', { desc = 'Copilot disable' })
      vim.keymap.set('n', cp .. 's', '<cmd>Copilot status<CR>', { desc = 'Copilot status' })
      vim.keymap.set('n', cp .. 'p', '<cmd>Copilot panel<CR>', { desc = 'Copilot panel' })
      vim.keymap.set('n', cp .. 'S', '<cmd>Copilot auth<CR>', { desc = 'Copilot auth' })
      -- stylua: ignore end
    end,
  },
}
