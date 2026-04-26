module = {}

module.init = function(filename)
  ---@type table | nil
  local attrs = hs.fs.attributes(filename)

  if attrs then
    ---@type table | nil
    local secrets = hs.json.read(filename)
    if secrets then
      for key, value in pairs(secrets) do
        hs.settings.set(key, value)
      end
    end
  end
end

return module
