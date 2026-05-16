local gh = _G.Config.github
local now = _G.Config.now
local later = _G.Config.later
local now_if_args = vim.fn.argc(-1) > 0 and now or later

-- Treesitter =================================================================

now(function()
  vim.pack.add({
    { src = gh('nvim-treesitter/nvim-treesitter'), version = 'main' },
    {
      src = gh('nvim-treesitter/nvim-treesitter-textobjects'),
      version = 'main',
    },
  })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { '<filetype>' },
    callback = function()
      vim.treesitter.start()
    end,
  })
end)

-- Language servers ===========================================================

-- Auto-configure lua language server
now_if_args(function()
  vim.pack.add({ gh('folke/lazydev.nvim') })
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
    },
  })
end)

now_if_args(function()
  vim.pack.add({ gh('neovim/nvim-lspconfig') })

  -- Manually enable language servers not managed by Mason
  vim.lsp.enable('sourcekit')
  vim.lsp.enable('lua_ls')
end)

-- Completions ================================================================

later(function()
  vim.pack.add({
    gh('saghen/blink.lib'),
    -- Copilot provider
    gh('fang2hou/blink-copilot'),
    -- Colorize menu items
    gh('xzbdmw/colorful-menu.nvim'),
    gh('saghen/blink.cmp'),
  })

  require('blink.cmp'):build()
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
            kind_icon = {
              highlight = function(ctx)
                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                return hl
              end,
            },
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
    signature = {
      enabled = false,
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
  vim.pack.add({ gh('stevearc/conform.nvim') })

  local conform = require('conform')

  ---@param bufnr integer Buffer number (defaults to current buffer)
  local function format_js(bufnr)
    local file = vim.api.nvim_buf_get_name(bufnr)

    local biome_root = vim.fs.root(file, { 'biome.json' })
    if biome_root and conform.get_formatter_info('biome', bufnr).available then
      return { 'biome' }
    end

    local deno_root = vim.fs.root(file, { 'deno.json', 'deno.jsonc' })
    if
      deno_root and conform.get_formatter_info('deno_fmt', bufnr).available
    then
      return { 'deno_fmt' }
    end

    return { 'prettier' }
  end

  conform.setup({
    formatters_by_ft = {
      blade = { 'prettier' },
      cs = { 'csharpier' },
      css = format_js,
      fish = { 'fish_indent' },
      html = { 'prettier' },
      javascript = format_js,
      javascriptreact = format_js,
      json = format_js,
      jsonc = format_js,
      lua = { 'stylua' },
      markdown = { 'prettier' },
      python = { 'ruff_format' },
      swift = { 'swift_format' },
      tex = { 'latexindent' },
      typescript = format_js,
      typescriptreact = format_js,
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
  vim.pack.add({ gh('tpope/vim-sleuth') })
  -- Disable sleuth for markdown files as it slows the load time significantly
  vim.g.sleuth_markdown_heuristics = 0
end)

-- External tools =============================================================

later(function()
  vim.pack.add({ gh('mason-org/mason.nvim') })
  require('mason').setup()

  vim.pack.add({ gh('mason-org/mason-lspconfig.nvim') })
  require('mason-lspconfig').setup({
    automatic_enable = true,
    ensure_installed = {},
  })
end)

-- Filetypes ==================================================================

-- Misc filetype support
now_if_args(function()
  vim.pack.add({
    gh('fladson/vim-kitty'),
    gh('mustache/vim-mustache-handlebars'),
    gh('jwalton512/vim-blade'),
    gh('cfdrake/vim-pbxproj'),
  })
end)

-- AI =========================================================================

later(function()
  vim.pack.add({ gh('pablopunk/pi.nvim') })
  require('pi').setup({
    provider = 'openai-codex',
    model = 'gpt-5.4',
    thinking = 'off',
  })
end)

-- Other functionality ========================================================

-- JSON schemas
-- May be needed by LS at startup, such as with `json_generating_cmd | vi -R -`
now(function()
  vim.pack.add({ gh('b0o/schemastore.nvim') })
end)

-- Better start/end matching
-- Matchup needs to load immediately at startup
now(function()
  vim.pack.add({ gh('andymass/vim-matchup') })
  vim.g.matchup_matchparen_offscreen = { method = 'popup' }
end)

-- Better git diff views
later(function()
  vim.pack.add({ gh('sindrets/diffview.nvim') })

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
