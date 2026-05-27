return {
  {
    'undotree',
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<cr>', desc = 'Toggle undotree' },
    },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_TreeNodeShape = '◉'
      -- vim.g.undotree_TreeVertShape = '│'
      -- vim.g.undotree_TreeSplitShape = '╱'
      -- vim.g.undotree_TreeReturnShape = '╲'
    end,
  },
}
