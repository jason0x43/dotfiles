local MiniDeps = require('mini.deps')
local add = MiniDeps.add
local now = MiniDeps.now
local later = MiniDeps.later
local now_if_args = vim.fn.argc(-1) > 0 and now or later

-- Treesitter =================================================================

now_if_args(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    hooks = {
      post_checkout = function()
        vim.cmd('TSUpdate')
      end,
    },
  })
  add({
    source = 'nvim-treesitter/nvim-treesitter-textobjects',
    -- Same logic as for 'nvim-treesitter'
    checkout = 'main',
  })

  require('nvim-treesitter.configs').setup({
    auto_install = true,
    sync_install = true,
    ensure_installed = { 'diff' },
    modules = {},
    ignore_install = {},
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    matchup = {
      enable = true,
    },
    context_commentstring = {
      enable = true,
    },
  })
end)

-- Lanuage servers ============================================================

now_if_args(function()
  add('neovim/nvim-lspconfig')

  -- Manually enable language servers not managed by Mason
  vim.lsp.enable('sourcekit')
end)

-- Auto-configure lua-ls
later(function()
  add('folke/lazydev.nvim')
  require('lazydev').setup({
    enabled = true,
    debug = false,
    runtime = vim.env.VIMRUNTIME,
    integrations = {
      lspconfig = true,
    },
    library = {
      -- Load luvit types when the `vim.uv` word is found
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      {
        path = 'nvim-lspconfig/lua',
        words = { 'lspconfig', 'lsp' },
      },
      {
        path = vim.fn.stdpath('config') .. '/lua/user/types/wezterm',
        words = { 'wezterm' },
      },
    },
  })
end)

-- Completions ================================================================

later(function()
  ---@type string | nil
  local checkout = 'v.1.7.0'

  if vim.fn.executable('rustc') then
    checkout = nil
  else
    -- Get latest pre-built version of blink
    local curl = require('plenary.curl')
    local res = curl.get(
      'https://api.github.com/repos/Saghen/blink.cmp/releases/latest',
      {
        headers = { ['User-Agent'] = 'neovim-lua' },
      }
    )
    if res.status ~= 200 then
      vim.notify(
        'Failed to get latest blink.cmp version: ' .. res.status,
        vim.log.levels.WARN
      )
    else
      local data = vim.fn.json_decode(res.body)
      checkout = data.tag_name
    end
  end

  -- build from source, requires nightly rust
  local function build_blink(params)
    vim.notify('Building blink.cmp', vim.log.levels.INFO)
    local obj = vim
      .system({ 'cargo', 'build', '--release' }, { cwd = params.path })
      :wait()
    if obj.code == 0 then
      vim.notify('Building blink.cmp done', vim.log.levels.INFO)
    else
      vim.notify('Building blink.cmp failed', vim.log.levels.ERROR)
    end
  end

  add({
    source = 'saghen/blink.cmp',
    depends = {
      -- Copilot provider
      'fang2hou/blink-copilot',
      -- Colorize menu items
      'xzbdmw/colorful-menu.nvim',
    },
    -- Checkout a specific version of blink to get pre-compiled rust part
    checkout = checkout,
    hooks = {
      post_checkout = build_blink,
      post_install = build_blink,
    },
  })

  require('blink.cmp').setup({
    cmdline = {
      enabled = false,
    },
    completion = {
      accept = {
        auto_brackets = {
          enabled = false,
        },
        dot_repeat = false,
      },
      documentation = {
        auto_show = true,
        window = {
          border = 'rounded',
        },
      },
      ghost_text = {
        enabled = false,
      },
      list = {
        selection = {
          preselect = false,
          auto_insert = true,
        },
      },
      menu = {
        draw = {
          columns = { { 'kind_icon' }, { 'label', gap = 1 } },
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
    },
    keymap = {
      preset = 'default',
      ['<C-e>'] = { 'select_and_accept', 'fallback' },
      -- ['<Tab>'] = {
      --   'snippet_forward',
      --   function()
      --     return require('sidekick').nes_jump_or_apply()
      --   end,
      --   'fallback',
      -- },
    },
    signature = {
      enabled = false,
      window = {
        border = 'rounded',
      },
    },
    sources = {
      default = { 'copilot', 'lsp', 'path', 'buffer', 'lazydev' },
      providers = {
        copilot = {
          name = 'copilot',
          module = 'blink-copilot',
          score_offset = 100,
          async = true,
        },
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          fallbacks = { 'lsp' },
        },
      },
    },
  })
end)

-- Formatting =================================================================

later(function()
  add('stevearc/conform.nvim')
  require('conform').setup({
    formatters_by_ft = {
      blade = { 'prettier' },
      cs = { 'csharpier' },
      css = { 'prettier' },
      fish = { 'fish_indent' },
      html = { 'prettier' },
      javascript = { 'prettier', 'deno_fmt' },
      javascriptreact = { 'prettier' },
      json = { 'prettier' },
      jsonc = { 'prettier' },
      lua = { 'stylua' },
      markdown = { 'prettier' },
      python = { 'ruff_format' },
      swift = { 'swift_format' },
      tex = { 'latexindent' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
    },
    formatters = {
      prettier = {
        cwd = require('conform.util').root_file({
          'package.json',
          'jsconfig.json',
          'tsconfig.json',
        }),
        require_cwd = false,
      },
      deno_fmt = {
        cwd = require('conform.util').root_file({
          'deno.json',
        }),
        require_cwd = true,
      },
      latexindent = {
        prepend_args = { '-m' },
      },
      csharpier = {
        command = 'csharpier',
        args = { 'format', '--write-stdout' },
      },
    },
  })

  vim.api.nvim_create_user_command('Format', function()
    require('conform').format({ lsp_fallback = true, async = true })
  end, { desc = 'Format the current file' })
end)

-- Auto-set indentation
now(function()
  add('tpope/vim-sleuth')
  -- Disable sleuth for markdown files as it slows the load time significantly
  vim.g.sleuth_markdown_heuristics = 0
end)

-- External tools =============================================================

later(function()
  add('mason-org/mason.nvim')
  require('mason').setup()

  add('mason-org/mason-lspconfig.nvim')
  require('mason-lspconfig').setup({
    automatic_enable = true,
    ensure_installed = {},
  })
end)

-- Filetypes ==================================================================

-- Misc filetype support
now_if_args(function()
  add('fladson/vim-kitty')
  add('mustache/vim-mustache-handlebars')
  add('jwalton512/vim-blade')
  add('cfdrake/vim-pbxproj')
end)

-- AI =========================================================================

-- opencode
later(function()
  add({
    source = 'sudo-tee/opencode.nvim',
    depends = { 'nvim-lua/plenary.nvim' },
  })

  require('opencode').setup({
    ui = {
      input = {
        text = {
          wrap = true,
        },
      },
      window_width = 80 / vim.o.columns,
    },
  })

  local opencode_group =
    vim.api.nvim_create_augroup('opencode_config', { clear = true })

  -- Enable linebreak in opencode windows
  vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
    group = opencode_group,
    callback = function()
      if vim.bo.filetype == 'opencode_output' then
        vim.wo.linebreak = true
      elseif vim.bo.filetype == 'opencode' then
        vim.wo.linebreak = true
      end
    end,
    desc = 'Enable linebreak in opencode output buffers',
  })

  -- Cleaner markdown rendering in opencode output panes
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  vim.g.render_markdown_config = {
    anti_conceal = { enabled = false },
    file_types = { 'opencode_output' },
  }
  add('MeanderingProgrammer/render-markdown.nvim')
end)

-- Other functionality ========================================================

-- JSON schemas
-- May be needed by LS at startup, such as with `json_generating_cmd | vi -R -`
now(function()
  add('b0o/schemastore.nvim')
end)

-- Better start/end matching
-- Matchup needs to load immediately at startup
now(function()
  add('andymass/vim-matchup')
  vim.g.matchup_matchparen_offscreen = { method = 'popup' }
end)

-- Better git diff views
later(function()
  add('sindrets/diffview.nvim')

  local last_status = vim.o.laststatus
  local actions = require('diffview.actions')
  local close_map = {
    'n',
    'q',
    actions.close,
    { desc = 'Close the diffview' },
  }

  require('diffview').setup({
    file_panel = {
      listing_style = 'list',
    },
    hooks = {
      view_opened = function()
        last_status = vim.o.laststatus
        vim.o.laststatus = 3
      end,
      view_closed = function()
        vim.o.laststatus = last_status
      end,
    },
    keymaps = {
      file_panel = {
        close_map,
        {
          'n',
          '<cr>',
          actions.focus_entry,
          { desc = 'Open the diff for the selected entry' },
        },
      },
      view = {
        close_map,
      },
    },
  })
  require('user.util.diffview').patch_layout()
end)

-- Semantic navigation
-- later(function()
--   add('Bekaboo/dropbar.nvim')
--   require('dropbar').setup({
--     sources = {
--       path = {
--         preview = false,
--       },
--     },
--   })
-- end)
