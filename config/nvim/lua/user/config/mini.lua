-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim',
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

require('mini.deps').setup({ path = { package = path_package } })

local add = MiniDeps.add
local now = MiniDeps.now
local later = MiniDeps.later

-- Git integration; used by statusline
now(function()
  require('mini.git').setup()

  local mini_util = require('user.util.mini')

  -- Modify how blame output is displayed
  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniGitCommandSplit',
    ---@param event MiniGitEvent
    callback = function(event)
      if event.data.git_subcommand ~= 'blame' then
        return
      end
      mini_util.show_git_blame(event.data)
    end,
  })

  vim.api.nvim_create_user_command('Blame', function()
    vim.cmd('lefta vertical Git blame -c --date=relative -- %:p')
  end, { desc = 'Show git blame info for the current file' })
end)

-- Start screen
now(function()
  local starter = require('mini.starter')
  starter.setup({
    evaluate_single = true,
    items = {
      {
        {
          action = 'Pick explorer',
          name = 'Explorer',
          section = 'Pickers',
        },
        {
          action = 'Pick files',
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
now(function()
  require('mini.pick').setup()
  require('mini.extra').setup()

  local mini_util = require('user.util.mini')

  MiniPick.registry.diagnostic = mini_util.picker_diagnostics
  MiniPick.registry.recent = mini_util.picker_recent
  MiniPick.registry.undotree = require('undotree-nvim').picker_undotree

  -- Use mini.pick as vim selector UI
  vim.ui.select = MiniPick.ui_select

  vim.keymap.set('n', '<leader>b', function()
    MiniPick.builtin.buffers()
  end, { desc = 'Find buffers' })

  vim.keymap.set('n', '<leader>d', function()
    MiniPick.registry.diagnostic({ scope = 'current' })
  end, { desc = 'List diagnostics' })

  vim.keymap.set('n', '<leader>f', function()
    MiniPick.builtin.files()
  end, { desc = 'Find files' })

  vim.keymap.set('n', '<leader>g', function()
    MiniPick.builtin.grep_live()
  end, { desc = 'Find strings in files' })

  vim.keymap.set('n', '<leader>h', function()
    MiniPick.builtin.help()
  end, { desc = 'Find help' })

  vim.keymap.set('n', '<leader>lr', function()
    MiniExtra.pickers.lsp({ scope = 'references' })
  end, { desc = 'Find help' })

  vim.keymap.set('n', '<leader>r', function()
    require('user.util.mini').picker_recent({ current_dir = true })
  end, { desc = 'Find recent files' })

  vim.keymap.set('n', '<leader>u', function()
    MiniPick.registry.undotree()
  end, { desc = 'List diagnostics' })

  -- Buffer removal
  require('mini.bufremove').setup()

  vim.keymap.set('n', '<leader>k', function()
    MiniBufremove.delete()
  end, { desc = 'Close the current buffer' })

  vim.keymap.set('n', '<leader>K', function()
    MiniBufremove.delete(0, true)
  end, { desc = 'Close the current buffer with prejudice' })
end)

-- File manager
now(function()
  require('mini.files').setup({
    mappings = {
      go_in = 'L',
      go_in_plus = 'l',
      go_out = 'H',
      go_out_plus = 'h',
    },
  })
  vim.keymap.set('n', '<leader>e', function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local dir = vim.fn.fnamemodify(bufname, ':p:h')
    MiniFiles.open(dir)
  end, { desc = 'Open a file explorer' })
end)

-- Diffing; used by status line
later(function()
  require('mini.diff').setup()
  vim.api.nvim_create_user_command('Diff', function()
    MiniDiff.toggle_overlay(0)
  end, { desc = 'Toggle a git diff overlay' })
end)

-- Icons
now(function()
  local icons = require('mini.icons')
  icons.setup()
  icons.mock_nvim_web_devicons()
end)

-- Status line
now(function()
  local sl = require('mini.statusline')
  local mini_util = require('user.util.mini')

  sl.setup({
    content = {
      active = function()
        local mode, mode_hl = sl.section_mode({ trunc_width = 120 })
        local git = sl.section_git({ trunc_width = 75 })
        local diagnostics =
          mini_util.section_diagnostics(sl, { trunc_width = 75 })
        local filename = sl.section_filename({ trunc_width = 140 })
        local location = sl.section_location({ trunc_width = 140 })
        local lsps = mini_util.section_lsps(sl, { trunc_width = 140 })

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
now(function()
  require('mini.notify').setup()
end)

-- Indent guides
later(function()
  require('mini.indentscope').setup({
    symbol = '│',
  })
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

-- Native LSP configurations --------------------------------------
now(function()
  add({ source = 'neovim/nvim-lspconfig' })
end)

-- Language server and tool installer -----------------------------
now(function()
  add({ source = 'mason-org/mason.nvim' })
  require('mason').setup({
    ui = { border = 'single' },
  })
end)

-- Mason language server manager ----------------------------------
now(function()
  add({ source = 'mason-org/mason-lspconfig.nvim' })
  require('mason-lspconfig').setup({
    automatic_enable = true,
    ensure_installed = {},
  })
end)

-- Treesitter -----------------------------------------------------
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
    ensure_installed = {},
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

-- Misc filetype support ------------------------------------------
now(function()
  add({ source = 'mustache/vim-mustache-handlebars' })
  add({ source = 'jwalton512/vim-blade' })
  add({ source = 'cfdrake/vim-pbxproj' })
end)

-- Auto-configure lua-ls ------------------------------------------
later(function()
  add({ source = 'folke/lazydev.nvim' })
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

-- Code formatting ------------------------------------------------
later(function()
  add({ source = 'stevearc/conform.nvim' })
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

  vim.keymap.set('n', '<leader>F', function()
    require('conform').format({ lsp_fallback = true, async = true })
  end, { desc = 'Format the current file' })
end)

-- Copilot integration --------------------------------------------
later(function()
  if vim.fn.executable('node') == 1 then
    add({ source = 'zbirenbaum/copilot.lua' })
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
  end

  add({
    source = 'CopilotC-Nvim/CopilotChat.nvim',
    depends = {
      'zbirenbaum/copilot.lua',
      'nvim-lua/plenary.nvim',
    },
    hooks = {
      post_checkout = function()
        vim.fn.system('make tiktoken')
      end,
    },
  })
  require('CopilotChat').setup()
end)

-- Better start/end matching --------------------------------------
add({ source = 'andymass/vim-matchup' })
vim.g.matchup_matchparen_offscreen = { method = 'popup', border = 'rounded' }

-- JSON schemas ---------------------------------------------------
add({ source = 'b0o/schemastore.nvim' })

-- Better git diff views ------------------------------------------
add({ source = 'sindrets/diffview.nvim' });
(function()
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
end)()

-- Auto-set indentation -------------------------------------------
add({ source = 'tpope/vim-sleuth' })
-- Disable sleuth for markdown files as it slows the load time significantly
vim.g.sleuth_markdown_heuristics = 0

-- Completions ----------------------------------------------------
add({
  source = 'saghen/blink.cmp',
  depends = {
    -- Copilot provider
    'giuxtaposition/blink-cmp-copilot',
    -- Colorize menu items
    'xzbdmw/colorful-menu.nvim',
  },
  -- Checkout a specific version of blink to get pre-compiled rust part
  checkout = 'v1.4.1',
});
(function()
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
    -- Add a copilot kind to blink's list of completion kinds
    local CompletionItemKind = require('blink.cmp.types').CompletionItemKind
    local copilot_kind = #CompletionItemKind + 1
    CompletionItemKind[copilot_kind] = 'Copilot'

    providers.copilot = {
      name = 'copilot',
      module = 'blink-cmp-copilot',
      score_offset = 100,
      async = true,
      transform_items = function(_, items)
        return vim.tbl_map(function(item)
          item.kind = copilot_kind
          return item
        end, items)
      end,
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
end)()

-- Use vim as kitty's scrollback handler --------------------------
add({ source = 'mikesmithgh/kitty-scrollback.nvim' })
require('kitty-scrollback').setup()

-- Kitty config filetype ------------------------------------------
add({ source = 'fladson/vim-kitty' })
