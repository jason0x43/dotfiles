local C = require('user.util.lsp').make_user_config()

---Add any jdtls-specific JVM args from the environment
local function get_jdtls_jvm_args()
  local args = {}
  for a in string.gmatch((os.getenv('JDTLS_JVM_ARGS') or ''), '%S+') do
    local arg = string.format('--jvm-arg=%s', a)
    table.insert(args, arg)
  end
  return unpack(args)
end

-- Update the server config when a new root directory is detected
C.config.on_new_config = function(new_config, new_root_dir)
  local workspace_dir = new_root_dir .. '/.jdtls/workspace'

  new_config.cmd = {
    'jdtls',
    '-configuration',
    new_root_dir .. '/.jdtls/config',
    '-data',
    workspace_dir,
    get_jdtls_jvm_args(),
  }

  new_config.init_options = {
    workspace = workspace_dir,
  }

  new_config.settings = {
    java = {
      project = {
        sourcePaths = {
          new_root_dir,
        },
      },
      autobuild = {
        enabled = true
      }
    },
  }
end

C.config.handlers = {
  ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
    ---@param diag vim.Diagnostic
    result.diagnostics = vim.tbl_filter(function(diag)
      -- Ignore diagnostic 16, which is "x is a non-project file"
      if diag.code == '16' then
        print(diag.message)
        return false
      end
      return true
    end, result.diagnostics)

    vim.lsp.handlers['textDocument/publishDiagnostics'](
      err,
      result,
      ctx,
      config
    )
  end,
}

return C
