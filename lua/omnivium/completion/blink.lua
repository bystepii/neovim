return {
  {
    'blink-cmp-conventional-commits',
    dep_of = { 'blink.cmp' },
  },
  {
    'blink-cmp-spell',
    dep_of = { 'blink.cmp' },
  },
  {
    'colorful-menu.nvim',
    on_plugin = { 'blink.cmp' },
  },
  {
    'blink.cmp',
    event = 'DeferredUIEnter',
    after = function(_)
      require('blink.cmp').setup({
        keymap = {
          preset = 'default',
          ['<C-space>'] = false,
          ['<Up>'] = false,
          ['<Down>'] = false,
          ['<Tab>'] = false,
          ['<S-Tab>'] = false,
          ['<C-s>'] = { 'show', 'show_documentation', 'hide_documentation', 'fallback' },
          ['<C-t>'] = { 'show_signature', 'hide_signature', 'fallback' },
          ['<C-e>'] = { 'hide', 'hide_documentation', 'hide_signature', 'fallback' },
          ['<C-y>'] = { 'select_and_accept', 'fallback' },
          ['<C-k>'] = { 'select_prev', 'fallback_to_mappings' },
          ['<C-j>'] = { 'select_next', 'fallback_to_mappings' },
          ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
          ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
          ['<C-n>'] = { 'snippet_forward', 'fallback' },
          ['<C-p>'] = { 'snippet_backward', 'fallback' },
        },
        cmdline = {
          enabled = true,
          keymap = { preset = 'inherit' },
          completion = {
            menu = {
              auto_show = true,
            },
          },
        },
        fuzzy = {
          sorts = {
            'exact',
            'score',
            'sort_text',
          },
        },
        signature = {
          enabled = true,
          window = {
            show_documentation = true,
          },
        },
        completion = {
          menu = {
            draw = {
              treesitter = { 'lsp' },
              components = {
                label = {
                  text = function(ctx)
                    return require('colorful-menu').blink_components_text(ctx)
                  end,
                  highlight = function(ctx)
                    return require('colorful-menu').blink_components_highlight(ctx)
                  end,
                },
              },
            },
          },
          documentation = {
            auto_show = true,
          },
        },
        snippets = {
          preset = 'luasnip',
          active = function(filter)
            local snippet = require('luasnip')
            local blink = require('blink.cmp')
            if snippet.in_snippet() and not blink.is_visible() then
              return true
            else
              if not snippet.in_snippet() and vim.fn.mode() == 'n' then
                snippet.unlink_current()
              end
              return false
            end
          end,
        },
        sources = {
          default = { 'spell', 'conventional_commits', 'lsp', 'path', 'snippets', 'buffer', 'omni' },
          providers = {
            path = {
              score_offset = 50,
            },
            lsp = {
              score_offset = 40,
            },
            snippets = {
              score_offset = 40,
            },
            cmdline = {
              score_offset = -100,
            },
            conventional_commits = {
              name = 'Conventional Commits',
              module = 'blink-cmp-conventional-commits',
              enabled = function()
                return vim.bo.filetype == 'gitcommit'
              end,
              opts = {},
            },
            spell = {
              name = 'Spell',
              module = 'blink-cmp-spell',
              opts = {
                use_cmp_spell_sorting = true,
                enable_in_context = function()
                  local curpos = vim.api.nvim_win_get_cursor(0)
                  local captures =
                    vim.treesitter.get_captures_at_pos(0, curpos[1] - 1, curpos[2] - 1)
                  local in_spell_capture = false
                  for _, cap in ipairs(captures) do
                    if cap.capture == 'spell' then
                      in_spell_capture = true
                    elseif cap.capture == 'nospell' then
                      return false
                    end
                  end
                  return in_spell_capture
                end,
              },
            },
          },
        },
      })
    end,
  },
}