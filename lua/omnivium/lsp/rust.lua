return {
  {
    'rust_analyzer',
    enabled = nixInfo(false, 'settings', 'devMode'),
    lsp = {
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
