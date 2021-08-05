-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/jason/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/jason/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/jason/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/jason/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/jason/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["FixCursorHold.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/FixCursorHold.nvim"
  },
  ["Navigator.nvim"] = {
    config = { "\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22plugins.Navigator\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/Navigator.nvim"
  },
  ["Textile-for-VIM"] = {
    loaded = false,
    needs_bufread = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/Textile-for-VIM"
  },
  ["applescript.vim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/applescript.vim"
  },
  ["denops.vim"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/denops.vim"
  },
  ["diffview.nvim"] = {
    commands = { "DiffviewOpen" },
    config = { "\27LJ\2\n6\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\rdiffview\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/diffview.nvim"
  },
  ["editorconfig-vim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/editorconfig-vim"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\n6\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\rgitsigns\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/gitsigns.nvim",
    wants = { "plenary.nvim" }
  },
  ["indent-blankline.nvim"] = {
    config = { "\27LJ\2\nd\0\0\2\0\5\0\t6\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\1\0+\1\1\0=\1\4\0K\0\1\0\29indent_blankline_enabled\b│\26indent_blankline_char\6g\bvim\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/indent-blankline.nvim"
  },
  ["jsonc.vim"] = {
    loaded = false,
    needs_bufread = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/jsonc.vim"
  },
  ["lsp_signature.nvim"] = {
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/lsp_signature.nvim"
  },
  ["lualine-lsp-progress"] = {
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/lualine-lsp-progress"
  },
  ["lualine.nvim"] = {
    config = { "\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20plugins.lualine\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/lualine.nvim"
  },
  neogit = {
    commands = { "Neogit" },
    config = { "\27LJ\2\n.\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\19plugins.neogit\frequire\0" },
    loaded = false,
    needs_bufread = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/neogit"
  },
  ["null-ls.nvim"] = {
    config = { "\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20plugins.null-ls\frequire\0" },
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/null-ls.nvim",
    wants = { "plenary.nvim" }
  },
  ["nvim-colorizer.lua"] = {
    config = { "\27LJ\2\n7\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\14colorizer\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/nvim-colorizer.lua"
  },
  ["nvim-compe"] = {
    after_files = { "/Users/jason/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe.vim" },
    config = { "\27LJ\2\n2\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\23plugins.nvim-compe\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/nvim-compe"
  },
  ["nvim-lsp-ts-utils"] = {
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/nvim-lsp-ts-utils"
  },
  ["nvim-lspconfig"] = {
    after = { "null-ls.nvim", "lualine-lsp-progress", "nvim-lsp-ts-utils", "lsp_signature.nvim", "vim-illuminate", "trouble.nvim", "nvim-lspinstall" },
    config = { "\27LJ\2\n#\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\blsp\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/nvim-lspconfig"
  },
  ["nvim-lspinstall"] = {
    config = { "\27LJ\2\n7\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\28plugins.nvim-lspinstall\frequire\0" },
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/nvim-lspinstall"
  },
  ["nvim-tree.lua"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n7\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\28plugins.nvim-treesitter\frequire\0" },
    loaded = false,
    needs_bufread = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  ["plenary.nvim"] = {
    after = { "popup.nvim" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/plenary.nvim"
  },
  ["popup.nvim"] = {
    load_after = {
      ["plenary.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/popup.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    after = { "telescope.nvim" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/telescope-fzf-native.nvim"
  },
  ["telescope-symbols.nvim"] = {
    load_after = {
      ["telescope.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/telescope-symbols.nvim"
  },
  ["telescope.nvim"] = {
    after = { "telescope-symbols.nvim" },
    config = { "\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22plugins.telescope\frequire\0" },
    load_after = {
      ["telescope-fzf-native.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/telescope.nvim",
    wants = { "plenary.nvim" }
  },
  ["trouble.nvim"] = {
    config = { "\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20plugins.trouble\frequire\0" },
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/trouble.nvim"
  },
  undotree = {
    commands = { "UndotreeToggle" },
    config = { "\27LJ\2\n0\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\21plugins.undotree\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/undotree"
  },
  ["vim-bbye"] = {
    commands = { "Bdelete" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-bbye"
  },
  ["vim-classpath"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-classpath"
  },
  ["vim-commentary"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-commentary"
  },
  ["vim-easy-align"] = {
    commands = { "EasyAlign" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-easy-align"
  },
  ["vim-fugitive"] = {
    loaded = false,
    needs_bufread = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-fugitive"
  },
  ["vim-illuminate"] = {
    config = { "\27LJ\2\n2\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\23plugins.illuminate\frequire\0" },
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-illuminate"
  },
  ["vim-markdown"] = {
    loaded = false,
    needs_bufread = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-markdown"
  },
  ["vim-markdown-toc"] = {
    loaded = false,
    needs_bufread = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc"
  },
  ["vim-matchup"] = {
    after_files = { "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-matchup/after/plugin/matchit.vim" },
    loaded = false,
    needs_bufread = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-matchup"
  },
  ["vim-polyglot"] = {
    loaded = false,
    needs_bufread = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-polyglot"
  },
  ["vim-repeat"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-repeat"
  },
  ["vim-startify"] = {
    config = { "\27LJ\2\n0\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\21plugins.startify\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-startify"
  },
  ["vim-startuptime"] = {
    commands = { "StartupTime" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-startuptime"
  },
  ["vim-surround"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-surround"
  },
  vimtex = {
    loaded = false,
    needs_bufread = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vimtex"
  }
}

time([[Defining packer_plugins]], false)
-- Setup for: editorconfig-vim
time([[Setup for editorconfig-vim]], true)
try_loadstring("\27LJ\2\nF\0\0\2\0\4\0\0056\0\0\0009\0\1\0'\1\3\0=\1\2\0K\0\1\0\tnone$EditorConfig_max_line_indicator\6g\bvim\0", "setup", "editorconfig-vim")
time([[Setup for editorconfig-vim]], false)
-- Setup for: nvim-tree.lua
time([[Setup for nvim-tree.lua]], true)
try_loadstring("\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22plugins.nvim-tree\frequire\0", "setup", "nvim-tree.lua")
time([[Setup for nvim-tree.lua]], false)
-- Setup for: vim-polyglot
time([[Setup for vim-polyglot]], true)
try_loadstring("\27LJ\2\nK\0\0\2\0\4\0\0056\0\0\0009\0\1\0005\1\3\0=\1\2\0K\0\1\0\1\3\0\0\15autoindent\rftdetect\22polyglot_disabled\6g\bvim\0", "setup", "vim-polyglot")
time([[Setup for vim-polyglot]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file StartupTime lua require("packer.load")({'vim-startuptime'}, { cmd = "StartupTime", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Bdelete lua require("packer.load")({'vim-bbye'}, { cmd = "Bdelete", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Neogit lua require("packer.load")({'neogit'}, { cmd = "Neogit", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file EasyAlign lua require("packer.load")({'vim-easy-align'}, { cmd = "EasyAlign", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewOpen lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file UndotreeToggle lua require("packer.load")({'undotree'}, { cmd = "UndotreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType textile ++once lua require("packer.load")({'Textile-for-VIM'}, { ft = "textile" }, _G.packer_plugins)]]
vim.cmd [[au FileType java ++once lua require("packer.load")({'vim-classpath'}, { ft = "java" }, _G.packer_plugins)]]
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'vim-markdown', 'vim-markdown-toc'}, { ft = "markdown" }, _G.packer_plugins)]]
vim.cmd [[au FileType tex ++once lua require("packer.load")({'vimtex'}, { ft = "tex" }, _G.packer_plugins)]]
vim.cmd [[au FileType applescript ++once lua require("packer.load")({'applescript.vim'}, { ft = "applescript" }, _G.packer_plugins)]]
vim.cmd [[au FileType latex ++once lua require("packer.load")({'vimtex'}, { ft = "latex" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au BufRead * ++once lua require("packer.load")({'gitsigns.nvim', 'indent-blankline.nvim'}, { event = "BufRead *" }, _G.packer_plugins)]]
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'nvim-compe'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre * ++once lua require("packer.load")({'nvim-tree.lua', 'nvim-treesitter', 'nvim-lspconfig', 'editorconfig-vim', 'jsonc.vim', 'plenary.nvim', 'vim-polyglot'}, { event = "BufReadPre *" }, _G.packer_plugins)]]
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'nvim-tree.lua', 'nvim-web-devicons', 'FixCursorHold.nvim', 'Navigator.nvim', 'vim-commentary', 'jsonc.vim', 'plenary.nvim', 'lualine.nvim', 'vim-repeat', 'vim-startify', 'vim-fugitive', 'nvim-colorizer.lua', 'vim-surround', 'telescope-fzf-native.nvim'}, { event = "VimEnter *" }, _G.packer_plugins)]]
vim.cmd [[au CursorMoved * ++once lua require("packer.load")({'vim-matchup'}, { event = "CursorMoved *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
vim.cmd [[augroup filetypedetect]]
time([[Sourcing ftdetect script at: /Users/jason/.local/share/nvim/site/pack/packer/opt/vim-markdown/ftdetect/markdown.vim]], true)
vim.cmd [[source /Users/jason/.local/share/nvim/site/pack/packer/opt/vim-markdown/ftdetect/markdown.vim]]
time([[Sourcing ftdetect script at: /Users/jason/.local/share/nvim/site/pack/packer/opt/vim-markdown/ftdetect/markdown.vim]], false)
time([[Sourcing ftdetect script at: /Users/jason/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc/ftdetect/markdown.vim]], true)
vim.cmd [[source /Users/jason/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc/ftdetect/markdown.vim]]
time([[Sourcing ftdetect script at: /Users/jason/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc/ftdetect/markdown.vim]], false)
time([[Sourcing ftdetect script at: /Users/jason/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tex.vim]], true)
vim.cmd [[source /Users/jason/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tex.vim]]
time([[Sourcing ftdetect script at: /Users/jason/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tex.vim]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
