local MP = ...
return {
  { import = MP:relpath('mini-base16') },
  { import = MP:relpath('which-key') },
  { import = MP:relpath('fidget') },
  { import = MP:relpath('neo-tree') },
  { import = MP:relpath('lualine') },
  { import = MP:relpath('hardtime') },
  { import = MP:relpath('highlight-colors') },
  { import = MP:relpath('illuminate') },
  { import = MP:relpath('nvim-numbertoggle') },
  -- NOTE: uncomment below as you add plugins to specs.ui.data in module.nix
  -- { import = MP:relpath('confirm-quit') },
  -- { import = MP:relpath('noice') },
  -- { import = MP:relpath('scope') },
  -- { import = MP:relpath('smart-splits') },
  { import = MP:relpath('trouble') },
  -- { import = MP:relpath('zen-mode') },
}
