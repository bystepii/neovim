return {
  {
    'crates.nvim',
    enabled = nixInfo(false, 'settings', 'devMode'),
    event = { 'BufReadPost Cargo.toml' },
    after = function(_)
      require('crates').setup({
        popup = {
          border = 'rounded',
        },
      })

      local function buf_map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = true, desc = desc })
      end

      vim.api.nvim_create_autocmd('BufReadPost', {
        pattern = 'Cargo.toml',
        callback = function()
          buf_map('n', '<leader>cu', require('crates').update_crate, '[C]rate [U]pdate')
          buf_map('n', '<leader>cU', require('crates').upgrade_crate, '[C]rate [U]pgrade')
          buf_map('n', '<leader>cH', require('crates').open_homepage, '[C]rate [H]omepage')
          buf_map('n', '<leader>cD', require('crates').open_documentation, '[C]rate [D]ocumentation')
        end,
      })
    end,
  },
}
