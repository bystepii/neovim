local MP = ...
-- NOTE: This config uses lzextras.lsp handler
-- https://github.com/BirdeeHub/lzextras?tab=readme-ov-file#lsp-handler
-- Because we have the paths, we can set a more performant fallback function
-- for when you don't provide a filetype to trigger on yourself.
-- If you do provide a filetype, this will never be called.

nixInfo.lze.h.lsp.set_ft_fallback(function(name)
  local lspcfg = nixInfo.get_nix_plugin_path('nvim-lspconfig')
  if lspcfg then
    local ok, cfg = pcall(dofile, lspcfg .. '/lsp/' .. name .. '.lua')
    return (ok and cfg or {}).filetypes or {}
  else
    -- the less performant thing we are trying to avoid at startup
    return (vim.lsp.config[name] or {}).filetypes or {}
  end
end)

return {
  {
    'nvim-lspconfig',
    lazy = false,
    on_require = { 'lspconfig' },
    -- NOTE: will run for all specs with type(plugin.lsp) == table
    -- when their filetype trigger loads them
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function(_)
      -- Blacklist unwanted bundled LSP from nvim-lspconfig
      vim.lsp.enable('gitlab_duo', false)

      -- Set up keymaps on LspAttach (fires after ANY LSP attaches, bypassing on_attach merge issues)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('omnivium-lsp-keymaps', { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end

          -- Ensure telescope is loaded before using it in keymaps
          local ok_telescope, tb = pcall(require, 'telescope.builtin')
          if not ok_telescope then
            vim.notify('Telescope not loaded, skipping LSP telescope keymaps', vim.log.levels.WARN)
            tb = nil
          end

          local nmap = function(keys, func, desc)
            if desc then
              desc = 'LSP: ' .. desc
            end
            local ok, err = pcall(vim.keymap.set, 'n', keys, func, { buffer = bufnr, desc = desc })
            if not ok then
              vim.notify(
                'Failed to set LSP keymap ' .. keys .. ': ' .. tostring(err),
                vim.log.levels.ERROR
              )
            end
          end

          -- Disable the LSP's formatting expression so 'gqgc' works (gwgc also
          -- works without this fix)
          -- https://vi.stackexchange.com/questions/39200/wrapping-comment-in-visual-mode-not-working-with-gq
          vim.bo[bufnr].formatexpr = nil

          local l = '<leader>l'
          -- stylua: ignore start
          nmap('gd',      vim.lsp.buf.definition,              '[G]oto [D]efinition')
          -- nmap('gr',      tb.lsp_references,                   '[G]oto [R]eferences')

          -- nmap(l .. 'd',  vim.lsp.buf.definition,              'Goto [D]efinition')
          if tb then
            nmap(l .. 'R',  tb.lsp_references,                   'Goto [R]eferences')
            nmap(l .. 'I',  tb.lsp_implementations,              'Goto [I]mplementation')
            nmap(l .. 'ds', tb.lsp_document_symbols,             '[D]ocument [S]ymbols')
            nmap(l .. 'ws', tb.lsp_dynamic_workspace_symbols,    '[W]orkspace [S]ymbols')
          end

          nmap(l .. 'r',  vim.lsp.buf.rename,                  '[R]ename')
          nmap(l .. 'ca', vim.lsp.buf.code_action,             '[C]ode [A]ction')
          nmap(l .. 'td', vim.lsp.buf.type_definition,         '[T]ype [D]efinition')
          nmap(l .. 'k',  vim.lsp.buf.hover,                   'Hover Documentation')
          nmap(l .. 'K',  vim.lsp.buf.signature_help,          'Signature Documentation')
          nmap(l .. 'D',  vim.lsp.buf.declaration,             'Goto [D]eclaration')
          nmap(l .. 'wa', vim.lsp.buf.add_workspace_folder,    '[W]orkspace [A]dd Folder')
          nmap(l .. 'wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
          nmap(l .. 'wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end,                                                 '[W]orkspace [L]ist Folders')
          -- stylua: ignore end

          -- NOTE: See conform.lua for formatting with lsp fallback
        end,
      })
    end,
  },
  { import = MP:relpath('bash') },
  { import = MP:relpath('clang') },
  { import = MP:relpath('copilot') },
  -- { import = MP:relpath('json') },
  { import = MP:relpath('just') },
  { import = MP:relpath('lua') },
  { import = MP:relpath('markdown') },
  { import = MP:relpath('nix') },
  { import = MP:relpath('python') },
  { import = MP:relpath('rust') },
  { import = MP:relpath('crates') },
  { import = MP:relpath('spell') },
}
