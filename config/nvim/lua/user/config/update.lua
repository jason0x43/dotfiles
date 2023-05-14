local registry = require('mason-registry')

local function update_mason()
  local note = vim.notify('Updating Mason packages...', vim.log.levels.INFO, {
    timeout = 2000,
  })

  local done = function()
    vim.notify('Done Updating Mason packages', vim.log.levels.INFO, {
      replace = note,
      timeout = 1000,
    })
  end

  local updating = {}
  local packages = registry.get_installed_packages()

  for _, pkg in ipairs(packages) do
    updating[pkg.name] = true
  end

  for _, pkg in ipairs(packages) do
    pkg:check_new_version(function(success, version)
      if success then
        note = vim.notify(
          ('Updating %s to %s'):format(pkg.name, version.latest_version),
          vim.log.levels.INFO,
          {
            replace = note,
            timeout = 2000,
          }
        )

        pkg:install():on('closed', function()
          updating[pkg.name] = nil

          vim.notify(
            ('Updated %s to %s'):format(pkg.name, version.latest_version),
            vim.log.levels.INFO
          )

          if vim.tbl_isempty(updating) then
            done()
          end
        end)
      else
        updating[pkg.name] = nil

        if vim.tbl_isempty(updating) then
          done()
        end
      end
    end)
  end
end

vim.api.nvim_create_user_command('Update', function()
  update_mason()
  vim.cmd('Lazy update')
  vim.cmd('TSUpdate')
end, {})
