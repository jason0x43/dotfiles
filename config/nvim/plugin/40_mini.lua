local now = _G.Config.now
local later = _G.Config.later
local now_if_args = vim.fn.argc(-1) > 0 and now or later

-- Now ========================================================================

-- Icons; used by status line and others
now(function()
  require('mini.icons').setup({
    lsp = {
      copilot = { glyph = '' },
    },
  })

  -- Mock 'nvim-tree/nvim-web-devicons' for plugins without 'mini.icons'
  -- support. Not needed for 'mini.nvim' or MiniMax, but might be useful for
  -- others.
  later(MiniIcons.mock_nvim_web_devicons)

  -- Add LSP kind icons. Useful for 'mini.completion'.
  later(MiniIcons.tweak_lsp_kind)
end)

-- Notifications
now(function()
  require('mini.notify').setup({
    content = {
      sort = function(notifications)
        return vim.tbl_filter(function(notif)
          local title = ''
          if notif.data and notif.data.response then
            title = notif.data.response.value.title
          end
          -- Filter out excessive notifications from jdtls
          return not (
            notif.data.source == 'lsp_progress'
            and (
              title:find('Publish Diagnostics')
              or title:find('Validate documents')
            )
          )
        end, notifications)
      end,
    },
  })
end)

-- Command line updates
now(function()
  require('mini.cmdline').setup()
end)

-- Start screen
if not (vim.list_contains(vim.v.argv, '-p')) then
  -- Only load the start screen if neovide wasn't started with '-p'
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
            action = 'Pick fff_files',
            name = 'Files',
            section = 'Pickers',
          },
          {
            action = 'Pick fff_content',
            name = 'Search',
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
            action = 'PackUpdate',
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
  end)
end

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

-- File manager
-- Load now to allow mini.files to open directories
now_if_args(function()
  require('mini.files').setup({
    mappings = {
      go_in = 'l',
      go_in_plus = '<CR>',
      go_out = 'H',
      go_out_plus = 'h',
    },
  })
end)

-- Later ======================================================================

-- Various extra functionality
later(function()
  require('mini.extra').setup()
end)

-- Buffer removal
later(function()
  require('mini.bufremove').setup()
end)

-- Diffing; used by status line
later(function()
  local diff = require('mini.diff')
  diff.setup({
    source = { diff.gen_source.git(), diff.gen_source.none() },
  })
end)

-- Git integration; used by statusline
later(function()
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

-- Colorizing
later(function()
  local function gen_highlighter_hex_color()
    local default_opts = {
      style = 'full',
      priority = 200,
      filter = function() return true end,
      inline_text = '█',
      max_number = nil,
    }
    opts = default_opts

    local style = opts.style
    local pattern = style == '#' and '()#()%x%x%x%x%x%x%x%x%f[%X]'
      or '#%x%x%x%x%x%x%x%x%f[%X]'
    local hl_style = (
      { full = 'bg', ['#'] = 'bg', line = 'line', inline = 'fg' }
    )[style] or 'bg'

    local extmark_opts = { priority = opts.priority }
    if opts.style == 'inline' then
      local priority, inline_text = opts.priority, opts.inline_text
      ---@diagnostic disable:cast-local-type
      extmark_opts = function(_, _, data)
        local virt_text = { { inline_text, data.hl_group } }
        return {
          virt_text = virt_text,
          virt_text_pos = 'inline',
          priority = priority,
          right_gravity = false,
        }
      end
    end

    local hex_opts = { max_number = opts.max_number }
    return {
      pattern = pattern,
      group = function(_, _, data)
        return MiniHipatterns.compute_hex_color_group(
          data.full_match,
          hl_style,
          hex_opts
        )
      end,
      extmark_opts = extmark_opts,
    }
  end

  local hipatterns = require('mini.hipatterns')
  hipatterns.setup({
    highlighters = {
      hex_color_alpha = gen_highlighter_hex_color(),
      hex_color = hipatterns.gen_highlighter.hex_color(),
      todo = { pattern = 'TODO', group = 'MiniHipatternsTodo' },
    },
  })

  local hex_color_groups = {}
  local n_hex_color_groups = 0
  local cu = require('user.util.color')

  ---@diagnostic disable-next-line: duplicate-set-field
  hipatterns.compute_hex_color_group = function(hex_color, style, opts)
    style = style or 'bg'
    local hex = hex_color:lower():sub(2)
    local group_name = string.format('MiniHipatterns_%s_%s', hex, style)

    local base = hex:sub(1, 6)
    local alpha = hex:sub(7, 8)
    local blended = cu.blend(
      base,
      vim.o.background == 'dark' and '#000000' or '#ffffff',
      #alpha == 2 and (tonumber(alpha, 16) / 255) or 1
    )

    -- Use manually tracked table instead of `vim.fn.hlexists()` because the
    -- latter still returns true for cleared highlights
    if hex_color_groups[group_name] then
      return group_name
    end

    -- Limit
    opts = vim.tbl_extend('force', { max_number = 10000 }, opts or {})
    if n_hex_color_groups >= opts.max_number then
      return nil
    end

    -- Define highlight group if it is not already defined
    local hl_opts
    -- - Compute opposite color based on Oklab lightness (for better contrast)
    if style == 'bg' then
      hl_opts = { fg = cu.compute_opposite_color(base), bg = blended }
    end
    if style == 'fg' then
      hl_opts = { fg = blended }
    end
    if style == 'line' then
      hl_opts = { sp = blended, underline = true }
    end

    local ok = pcall(vim.api.nvim_set_hl, 0, group_name, hl_opts)

    -- Keep track of created groups to properly react on `:hi clear`
    hex_color_groups[group_name] = ok
    n_hex_color_groups = n_hex_color_groups + (ok and 1 or 0)

    return ok and group_name or nil
  end
end)

-- Indent guides
later(function()
  require('mini.indentscope').setup({
    symbol = '│',
  })

  -- Only use indentscope with real files
  _G.Config.new_autocmd('BufEnter', '*', function()
    if vim.o.buftype == 'nofile' then
      vim.b.miniindentscope_disable = true
    end
  end, 'Disable indentscope in nofile buffers')
end)

-- Move text
later(function()
  require('mini.move').setup()
end)

-- Pickers
later(function()
  local pick = require('mini.pick')
  local default_show = pick.default_show

  pick.setup({
    mappings = {
      refine = '<M-r>',
    },

    source = {
      -- Override the default show function to relativize paths
      show = function(buf, items, query, opts)
        for _, v in ipairs(items) do
          if type(v.text) == 'string' and type(v.bufnr) == 'number' then
            v.text = vim.fn.fnamemodify(v.text, ':.')
          end
        end

        -- Fall back to the default renderer
        return default_show(buf, items, query, opts)
      end,
    },
    window = {
      config = function()
        -- The height of the picker
        local height = math.min(10, math.floor(0.4 * vim.o.lines))
        -- The width of the picker (screen width - border)
        local width = vim.o.columns - 2
        -- The row the picker should be drawn at
        -- (screen height - picker height - border - cmdline height)
        local row = vim.o.lines - height - 2 - 0

        -- Raise the picker above the statusbar if the statusbar is visible
        if vim.o.laststatus > 0 then
          row = row - 1
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

  MiniPick.registry.diagnostic = require('user.mini.picker_diagnostics')
  MiniPick.registry.recent = require('user.mini.picker_recent')
  MiniPick.registry.undotree = require('user.mini.picker_undo')
  MiniPick.registry.commandbar = require('user.mini.picker_commandbar')
  MiniPick.registry.smart = require('user.mini.picker_smarter')
  MiniPick.registry.icons = require('user.mini.picker_icons')
  MiniPick.registry.modified = require('user.mini.picker_modified')
  MiniPick.registry.conflicts = require('user.mini.picker_conflicts')
  MiniPick.registry.fff_files = require('user.mini.picker_fff').files
  MiniPick.registry.fff_content = require('user.mini.picker_fff').content

  -- Use mini.pick as vim selector UI
  vim.ui.select = MiniPick.ui_select
end)

-- Surround
later(function()
  require('mini.surround').setup()
end)

-- Track file visits
later(function()
  require('mini.visits').setup()
end)

-- Use 'q' to close vim.pack windows
later(function()
  _G.Config.new_autocmd('FileType', 'nvim-pack', function()
    vim.wo.foldlevel = 0
    vim.keymap.set('n', 'q', function()
      vim.cmd('close')
    end, { buffer = 0, desc = 'Close the pack pane' })
  end, 'Close vim.pack windows with "q"')
end)
