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
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/FixCursorHold.nvim"
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
  ["editorconfig-vim"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/editorconfig-vim"
  },
  fzf = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/fzf"
  },
  ["fzf.vim"] = {
    config = { "\27LJ\2\n+\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\16plugins.fzf\frequire\0" },
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/fzf.vim"
  },
  ["jsonc.vim"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/jsonc.vim"
  },
  ["lsp-colors.nvim"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/lsp-colors.nvim"
  },
  ["lualine-lsp-progress"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/lualine-lsp-progress"
  },
  ["lualine.nvim"] = {
    config = { "\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20plugins/lualine\frequire\0" },
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/lualine.nvim"
  },
  ["nvim-colorizer.lua"] = {
    config = { "\27LJ\2\n;\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\14colorizer\frequire\0" },
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua"
  },
  ["nvim-compe"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/nvim-compe"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\2\n”\1\0\0\3\0\6\0\0166\0\0\0'\2\1\0B\0\2\0016\0\0\0'\2\2\0B\0\2\0016\0\0\0'\2\3\0B\0\2\0029\0\4\0004\2\0\0B\0\2\0016\0\0\0'\2\5\0B\0\2\1K\0\1\0\20plugins.trouble\nsetup\15lsp-colors\23plugins.nvim-compe\21plugins.nvim-lsp\frequire\0" },
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-lspinstall"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/nvim-lspinstall"
  },
  ["nvim-tree.lua"] = {
    config = { "\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22plugins.nvim-tree\frequire\0" },
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22config.treesitter\frequire\0" },
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  ["trouble.nvim"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/trouble.nvim"
  },
  undotree = {
    config = { "\27LJ\2\n0\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\21plugins.undotree\frequire\0" },
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/undotree"
  },
  ["vim-bbye"] = {
    config = { "\27LJ\2\n0\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\21plugins.vim-bbye\frequire\0" },
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/vim-bbye"
  },
  ["vim-classpath"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vim-classpath"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/vim-commentary"
  },
  ["vim-easy-align"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/vim-easy-align"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/vim-fugitive"
  },
  ["vim-illuminate"] = {
    config = { "\27LJ\2\n2\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\23plugins.illuminate\frequire\0" },
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/vim-illuminate"
  },
  ["vim-lastplace"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/vim-lastplace"
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
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/vim-matchup"
  },
  ["vim-plugin-AnsiEsc"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/vim-plugin-AnsiEsc"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/vim-repeat"
  },
  ["vim-startify"] = {
    config = { "\27LJ\2\n0\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\21plugins.startify\frequire\0" },
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/vim-startify"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/vim-surround"
  },
  ["vim-tmux-navigator"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/vim-tmux-navigator"
  },
  ["vim-unimpaired"] = {
    loaded = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/start/vim-unimpaired"
  },
  vimtex = {
    loaded = false,
    needs_bufread = true,
    path = "/Users/jason/.local/share/nvim/site/pack/packer/opt/vimtex"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: nvim-colorizer.lua
time([[Config for nvim-colorizer.lua]], true)
try_loadstring("\27LJ\2\n;\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\14colorizer\frequire\0", "config", "nvim-colorizer.lua")
time([[Config for nvim-colorizer.lua]], false)
-- Config for: vim-startify
time([[Config for vim-startify]], true)
try_loadstring("\27LJ\2\n0\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\21plugins.startify\frequire\0", "config", "vim-startify")
time([[Config for vim-startify]], false)
-- Config for: vim-illuminate
time([[Config for vim-illuminate]], true)
try_loadstring("\27LJ\2\n2\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\23plugins.illuminate\frequire\0", "config", "vim-illuminate")
time([[Config for vim-illuminate]], false)
-- Config for: undotree
time([[Config for undotree]], true)
try_loadstring("\27LJ\2\n0\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\21plugins.undotree\frequire\0", "config", "undotree")
time([[Config for undotree]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\n”\1\0\0\3\0\6\0\0166\0\0\0'\2\1\0B\0\2\0016\0\0\0'\2\2\0B\0\2\0016\0\0\0'\2\3\0B\0\2\0029\0\4\0004\2\0\0B\0\2\0016\0\0\0'\2\5\0B\0\2\1K\0\1\0\20plugins.trouble\nsetup\15lsp-colors\23plugins.nvim-compe\21plugins.nvim-lsp\frequire\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: vim-bbye
time([[Config for vim-bbye]], true)
try_loadstring("\27LJ\2\n0\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\21plugins.vim-bbye\frequire\0", "config", "vim-bbye")
time([[Config for vim-bbye]], false)
-- Config for: nvim-tree.lua
time([[Config for nvim-tree.lua]], true)
try_loadstring("\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22plugins.nvim-tree\frequire\0", "config", "nvim-tree.lua")
time([[Config for nvim-tree.lua]], false)
-- Config for: fzf.vim
time([[Config for fzf.vim]], true)
try_loadstring("\27LJ\2\n+\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\16plugins.fzf\frequire\0", "config", "fzf.vim")
time([[Config for fzf.vim]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
try_loadstring("\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20plugins/lualine\frequire\0", "config", "lualine.nvim")
time([[Config for lualine.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22config.treesitter\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType java ++once lua require("packer.load")({'vim-classpath'}, { ft = "java" }, _G.packer_plugins)]]
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'vim-markdown', 'vim-markdown-toc'}, { ft = "markdown" }, _G.packer_plugins)]]
vim.cmd [[au FileType tex ++once lua require("packer.load")({'vimtex'}, { ft = "tex" }, _G.packer_plugins)]]
vim.cmd [[au FileType applescript ++once lua require("packer.load")({'applescript.vim'}, { ft = "applescript" }, _G.packer_plugins)]]
vim.cmd [[au FileType textile ++once lua require("packer.load")({'Textile-for-VIM'}, { ft = "textile" }, _G.packer_plugins)]]
vim.cmd [[au FileType latex ++once lua require("packer.load")({'vimtex'}, { ft = "latex" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
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
