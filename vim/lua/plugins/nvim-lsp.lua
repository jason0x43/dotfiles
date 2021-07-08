local util = require('util')
local lspconfig = require('lspconfig')
local lspinstall = require('lspinstall')

lspinstall.setup()

local function configure_lsp(client, bufnr)
  local opts = { buffer = bufnr }
  if client.resolved_capabilities.goto_definition then
    util.keys.nmap('<C-]>', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  end
  if client.resolved_capabilities.hover then
    util.keys.map('K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  end
  util.keys.lmap('r', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  util.keys.lmap('e', '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>', opts)
  util.keys.lmap('d', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>', opts)
end

-- setup all the currently installed servers
local function setup_servers()
  local function not_deno(name)
    return name ~= 'deno'
  end
  local servers = vim.filter(not_deno, lspinstall.installed_servers())

  for _, server in pairs(servers) do
    local config = {}

    if server == 'efm' then
      local eslint = {
        lintCommand = 'eslint_d -f unix --stdin --stdin-filename ${INPUT}',
        lintStdin = true,
        lintIgnoreExitCode = true,
      }
      local prettier = {
        formatCommand = 'prettier'
      }
      config.filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
      }
      config.settings = {
        rootMarkers = { '.git/' },
        languages = {
          javascript = { eslint, prettier },
          javacriptreact = { eslint, prettier },
          typescript = { eslint, prettier },
          typecriptreact = { eslint, prettier },
        }
      }
    end

    lspconfig[server].setup(config)
  end
end

setup_servers()

-- automatically reload servers after `:LspInstall <server>`
lspinstall.post_install_hook = function ()
  setup_servers()
  vim.cmd("bufdo e")
end

_G.lsp_util = {}
local lsp_util = _G.lsp_util

function lsp_util.list_servers()
  print(vim.inspect(lspinstall.installed_servers()))
end

function lsp_util.update_servers()
  for _, server in pairs(lspinstall.installed_servers()) do
    lspinstall.install_server(server)
  end
end

util.cmd('LspList', ':lua lsp_util.list_servers()<cr>')
util.cmd('LspUpdate', ':lua lsp_util.update_servers()<cr>')
