-- copilot-lsp plugin config
-- This plugin is loaded as a dependency for copilot.lua NES (Next Edit Suggestion)
-- The actual copilot.lua setup is in lua/omnivium/ai/copilot.lua
return {
  {
    'copilot-lsp',
    lazy = true,
    dep_of = { 'copilot.lua' },
    before = function()
      vim.g.copilot_nes_debounce = 500
    end,
  },
}
