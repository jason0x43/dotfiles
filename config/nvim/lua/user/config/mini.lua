-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/nvim-mini/mini.nvim',
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

require('mini.deps').setup({ path = { package = path_package } })

vim.api.nvim_create_augroup('plugin_autocmds', {})

local add = MiniDeps.add
local now = MiniDeps.now
local later = MiniDeps.later

-- Load now -----------------------------------------------------------

-- Extra functions
now(function()
  add('nvim-lua/plenary.nvim')
end)

-- Track file visits
now(function()
  require('mini.visits').setup()
end)

-- File manager
-- Load now to allow mini.files to open directories
now(function()
  require('mini.files').setup({
    mappings = {
      go_in = 'l',
      go_in_plus = '<CR>',
      go_out = 'H',
      go_out_plus = 'h',
    },
  })
end)

-- Git integration; used by statusline
now(function()
  require('mini.git').setup()

  -- Modify how blame output is displayed
  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniGitCommandSplit',
    ---@param event MiniGitEvent
    callback = function(event)
      if event.data.git_subcommand ~= 'blame' then
        return
      end
      require('user.mini.git').show_git_blame(event.data)
    end,
  })

  vim.api.nvim_create_user_command('Blame', function()
    vim.cmd('lefta vertical Git blame -c --date=relative -- %:p')
  end, { desc = 'Show git blame info for the current file' })
end)

-- Diffing; used by status line
now(function()
  local diff = require('mini.diff')
  diff.setup({
    source = { diff.gen_source.git(), diff.gen_source.none() },
  })

  vim.api.nvim_create_user_command('Diff', function()
    MiniDiff.toggle_overlay(0)
  end, { desc = 'Toggle a git diff overlay' })
end)

-- Icons; used by status line
now(function()
  local icons = require('mini.icons')
  icons.setup()
  icons.mock_nvim_web_devicons()
end)

-- Status line
now(function()
  local sl = require('mini.statusline')
  local mini_status = require('user.mini.status')

  sl.setup({
    content = {
      active = function()
        local mode, mode_hl = sl.section_mode({ trunc_width = 120 })
        local git = sl.section_git({ trunc_width = 75 })
        local diagnostics =
          mini_status.section_diagnostics(sl, { trunc_width = 75 })
        local filename = sl.section_filename({ trunc_width = 140 })
        local location = sl.section_location({ trunc_width = 140 })
        local lsps = mini_status.section_lsps(sl, { trunc_width = 140 })

        return sl.combine_groups({
          { hl = mode_hl, strings = { mode } },
          {
            hl = 'MiniStatuslineDevInfo',
            strings = { git, diagnostics },
          },
          '%<', -- begin left alignment
          { hl = 'MiniStatuslineFilename', strings = { filename } },
          '%=', -- end left alignment
          { hl = 'MiniStatuslineDevInfo', strings = { lsps } },
          { hl = mode_hl, strings = { location } },
        })
      end,
      inactive = function()
        local filename = sl.section_filename({})
        return sl.combine_groups({
          { hl = 'MiniStatuslineFilename', strings = { filename } },
        })
      end,
    },
  })
  -- Don't show the mode on the last line since it's in the status line
  vim.o.showmode = false
end)

-- Start screen
now(function()
  local starter = require('mini.starter')
  starter.setup({
    evaluate_single = true,
    items = {
      {
        {
          action = function()
            MiniFiles.open()
          end,
          name = 'Explore',
          section = 'Pickers',
        },
        {
          action = 'Pick smart',
          name = 'Files',
          section = 'Pickers',
        },
        {
          action = 'Pick grep_live',
          name = 'Grep',
          section = 'Pickers',
        },
        {
          action = 'Pick recent current_dir=true',
          name = 'Recent',
          section = 'Pickers',
        },
        {
          action = function()
            MiniExtra.pickers.visit_paths({
              filter = function(opts)
                local suffix = 'COMMIT_EDITMSG'
                return opts.path:sub(-#suffix) ~= suffix
              end,
            })
          end,
          name = 'Visited',
          section = 'Pickers',
        },
        {
          action = 'Pick help',
          name = 'Help',
          section = 'Pickers',
        },
      },
      {
        {
          name = 'Close',
          action = 'enew',
          section = 'Actions',
        },
        {
          name = 'Dependencies',
          action = 'DepsUpdate',
          section = 'Actions',
        },
        {
          name = 'Tools',
          action = 'Mason',
          section = 'Actions',
        },
        {
          name = 'Yazi',
          action = function()
            require('user.config.yazi').open_yazi()
          end,
          section = 'Actions',
        },
        {
          name = 'Quit',
          action = 'qall',
          section = 'Actions',
        },
      },
    },
    header = '',
    footer = '',
  })

  local orig_ministarter_open = MiniStarter.open

  ---@diagnostic disable-next-line: duplicate-set-field
  MiniStarter.open = function()
    -- Hide UI elements
    vim.o.laststatus = 0
    vim.opt_local.fillchars = 'eob: '

    orig_ministarter_open()
  end

  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniStarterOpened',
    callback = function()
      -- Restore when leaving starter buffer
      vim.api.nvim_create_autocmd('BufUnload', {
        buffer = 0,
        once = true,
        callback = function()
          vim.o.laststatus = 2
        end,
      })
    end,
  })

  vim.api.nvim_create_user_command('Start', function()
    MiniStarter.open()
  end, { desc = 'Open the mini starter screen' })
end)

-- Use vim as kitty's scrollback handler
now(function()
  add('mikesmithgh/kitty-scrollback.nvim')
  require('kitty-scrollback').setup()
end)

-- Kitty config filetype
now(function()
  add('fladson/vim-kitty')
end)

-- Colorizing
now(function()
  local hipatterns = require('mini.hipatterns')
  hipatterns.setup({
    highlighters = {
      hex_color = hipatterns.gen_highlighter.hex_color(),
      todo = { pattern = 'TODO', group = 'MiniHipatternsTodo' },
    },
  })
end)

-- Native LSP configurations
now(function()
  add('neovim/nvim-lspconfig')
end)

-- Language server and tool installer
now(function()
  add('mason-org/mason.nvim')
  require('mason').setup({
    ui = { border = 'single' },
  })

  add('mason-org/mason-lspconfig.nvim')
  require('mason-lspconfig').setup({
    automatic_enable = true,
    ensure_installed = {},
  })
end)

-- Treesitter
now(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    hooks = {
      post_checkout = function()
        vim.cmd('TSUpdate')
      end,
    },
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

-- Misc filetype support
now(function()
  add('mustache/vim-mustache-handlebars')
  add('jwalton512/vim-blade')
  add('cfdrake/vim-pbxproj')
end)

-- JSON schemas
now(function()
  add('b0o/schemastore.nvim')
end)

-- Auto-set indentation
now(function()
  add('tpope/vim-sleuth')
  -- Disable sleuth for markdown files as it slows the load time significantly
  vim.g.sleuth_markdown_heuristics = 0
end)

-- Load later ---------------------------------------------------------

-- Use 'q' to close mini.deps windows
later(function()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'minideps-confirm',
    callback = function()
      vim.wo.foldlevel = 0
      vim.keymap.set('n', 'q', function()
        vim.cmd('close')
      end, { buffer = 0, desc = 'Close the deps pane' })
    end,
  })
end)

-- Pickers
later(function()
  require('mini.pick').setup({
    window = {
      config = function()
        local height = math.min(10, math.floor(0.4 * vim.o.lines))
        local width = vim.o.columns - 2
        local row = vim.o.lines - height - 4
        if vim.o.filetype == 'ministarter' then
          row = row + 2
        end

        return {
          anchor = 'NW',
          height = height,
          width = width,
          row = row,
          col = 0,
        }
      end,
    },
  })
  require('mini.extra').setup()

  MiniPick.registry.diagnostic = require('user.mini.picker_diagnostics')
  MiniPick.registry.recent = require('user.mini.picker_recent')
  MiniPick.registry.undotree = require('user.mini.picker_undo')
  MiniPick.registry.smart = require('user.mini.picker_smart')
  -- MiniPick.registry.smart = require('user.mini.picker_smartpick')

  -- Use mini.pick as vim selector UI
  vim.ui.select = MiniPick.ui_select
end)

-- Buffer removal
later(function()
  require('mini.bufremove').setup()
end)

-- Surround
later(function()
  require('mini.surround').setup()
end)

-- Jumping around
later(function()
  require('mini.jump2d').setup()
end)

-- Move text
later(function()
  require('mini.move').setup()
end)

-- Notifications
later(function()
  require('mini.notify').setup()
end)

-- Indent guides
later(function()
  require('mini.indentscope').setup({
    symbol = '│',
  })

  -- Only use indentscope with real files
  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    group = 'plugin_autocmds',
    callback = function()
      if vim.o.buftype == "nofile" then
        vim.b.miniindentscope_disable = true
      end
    end,
    desc = 'Setup DropBar menu buffers',
  })
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

-- Code formatting
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

-- Better start/end matching
later(function()
  add('andymass/vim-matchup')
  vim.g.matchup_matchparen_offscreen = { method = 'popup', border = 'rounded' }
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

-- Copilot
later(function()
  add('zbirenbaum/copilot.lua')
  require('copilot').setup({
    event = 'InsertEnter',
    suggestion = {
      enabled = false,
      auto_trigger = true,
    },
    panel = { enabled = false },
    filetypes = {
      ['*'] = function()
        return vim.bo.filetype ~= 'bigfile'
      end,
    },
  })
end)

-- Completions
later(function()
  ---@type string | nil
  local checkout = 'v.1.6.0'

  if vim.fn.executable('rustc') then
    checkout = nil
  else
    -- Get latest pre-build version of blink
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
  local providers = {
    lazydev = {
      name = 'LazyDev',
      module = 'lazydev.integrations.blink',
      fallbacks = { 'lsp' },
    },
  }
  local default = { 'lsp', 'path', 'buffer', 'lazydev' }

  -- Only add the copilot provider if copilot is active
  local ok, _ = pcall(require, 'copilot.api')
  if ok then
    providers.copilot = {
      name = 'copilot',
      module = 'blink-copilot',
      score_offset = 100,
      async = true,
    }
    table.insert(default, 2, 'copilot')
  end

  require('blink.cmp').setup({
    appearance = {
      -- Add a copilot icon to the default set
      kind_icons = vim.tbl_extend(
        'force',
        require('blink.cmp.config.appearance').default.kind_icons,
        {
          Copilot = '',
        }
      ),
    },
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
    },
    signature = {
      enabled = false,
      window = {
        border = 'rounded',
      },
    },
    sources = {
      default = default,
      providers = providers,
    },
  })
end)

later(function()
  add('Bekaboo/dropbar.nvim')
  require('dropbar').setup({
    sources = {
      path = {
        preview = false,
      },
    },
  })
end)

-- CodeCompanion
-- This should be loaded after blink for proper integration
later(function()
  local function build_mcphub()
    vim.notify('Installing mcp-hub', vim.log.levels.INFO)
    local obj = vim.system({ 'npm', 'install', '-g', 'mcp-hub@latest' }):wait()
    if obj.code == 0 then
      vim.notify('Installed mcp-hub', vim.log.levels.INFO)
    else
      vim.notify('Error installing mcp-hub', vim.log.levels.ERROR)
    end
  end

  add({
    source = 'ravitemer/mcphub.nvim',
    depends = { 'nvim-lua/plenary.nvim' },
    hooks = {
      post_checkout = build_mcphub,
      post_install = build_mcphub,
    },
  })

  require('mcphub').setup()

  -- Formatting for mcphub buffers
  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    group = 'plugin_autocmds',
    callback = function()
      if vim.o.filetype == "mcphub" then
        vim.o.linebreak = true
      end
    end,
    desc = 'Setup DropBar menu buffers',
  })

  add({
    source = 'olimorris/codecompanion.nvim',
    depends = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  })

  require('codecompanion').setup({
    extensions = {
      mcphub = {
        callback = 'mcphub.extensions.codecompanion',
      },
    },
    strategies = {
      chat = {
        adapter = 'copilot',
        keymaps = {
          -- use C-c for stop so we can use q for close
          stop = {
            modes = { n = '<C-c>' },
          },
        },
      },
      inline = {
        adapter = 'copilot',
      },
      cmd = {
        adapter = 'copilot',
      },
    },
    display = {
      chat = {
        -- window = {
        --   width = 0.5,
        --   opts = {
        --     number = false,
        --     concealcursor = 'n',
        --     conceallevel = 2,
        --   },
        -- },
        -- window = {
        --   layout = 'horizontal',
        --   position = 'bottom',
        --   height = 0.4,
        -- },
        window = {
          layout = 'float',
          height = 0.75,
          width = 0.75,
          opts = {
            number = false,
            concealcursor = 'n',
            conceallevel = 2,
          },
        },
      },
    },
  })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'codecompanion',
    callback = function()
      vim.keymap.set('n', 'q', '<cmd>CodeCompanionChat Toggle<cr>', {
        desc = 'Close the chat window',
        buffer = 0,
      })
    end,
    desc = 'Enhance CodeCompanion windows.',
  })

  add({
    source = 'MeanderingProgrammer/render-markdown.nvim',
    depends = {
      'nvim-treesitter',
      'nvim-mini/mini.nvim',
    },
  })
  require('render-markdown').setup({
    anti_conceal = { enabled = false },
    file_types = {
      'markdown',
      'codecompanion',
    },
    win_options = {
      conceallevel = {
        default = vim.o.conceallevel,
        rendered = 3,
      },
      concealcursor = {
        default = vim.o.concealcursor,
        rendered = 'n',
      },
    },
  })
end)
