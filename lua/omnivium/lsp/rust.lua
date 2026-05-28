return {
  {
    'rust_analyzer',
    enabled = nixInfo(false, 'settings', 'devMode'),
    lsp = {
      filetypes = { 'rust' },
      settings = {
        ['rust-analyzer'] = {
          checkOnSave = true,
          check = {
            command = 'clippy',
          },
          inlayHints = {
            enable = true,
          },
        },
      },
    },
  },
}
