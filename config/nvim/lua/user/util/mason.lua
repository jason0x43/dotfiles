local M = {}

M.upgrade = function()
  local to_check = 0
  local updating = 0

  local function check_done()
    if updating == 0 and to_check == 0 then
      io.write('Finished updating\n')

      vim.schedule(function()
        vim.api.nvim_exec_autocmds('User', {
          pattern = 'MasonUpgradeComplete',
        })
      end)
    end
  end

  io.write('Checking for updates...\n')

  local registry = require('mason-registry')

  -- This is blocking when called without a callback
  registry.refresh()
  io.write('Refreshed registry\n')

  registry.update(function(success, error)
    if not success then
      io.write('Error updating registry: ' .. error)
      vim.schedule(function()
        vim.api.nvim_exec_autocmds('User', {
          pattern = 'MasonUpgradeComplete',
        })
      end)

      return
    else
      io.write('Updated registry\n')
    end

    local packages = registry.get_installed_packages()
    to_check = #packages

    io.write('Checking ' .. to_check .. ' packages...\n')

    if to_check == 0 then
      check_done()
    else
      for _, pkg in ipairs(packages) do
        updating = updating + 1
        to_check = to_check - 1

        pkg:check_new_version(function(new_available, version)
          if new_available then
            pkg:on('install:success', function()
              io.write(
                ('Updated %s to %s\n'):format(pkg.name, version.latest_version)
              )
              updating = updating - 1
              check_done()
            end)

            pkg:on('install:failure', function()
              io.write(('Error updating %s\n'):format(pkg.name))
              updating = updating - 1
              check_done()
            end)

            io.write(
              ('Updating %s to %s...\n'):format(
                pkg.name,
                version.latest_version
              )
            )
            pkg:install({ version = version.latest_version, force = true })
          else
            updating = updating - 1
            check_done()
          end
        end)
      end
    end
  end)
end

return M
