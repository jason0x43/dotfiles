module = {}

module.init = function(filename)
  ---@type table | nil
  local attrs = hs.fs.attributes(filename)

  if attrs then
    ---@type table | nil
    local settings = hs.json.read(filename)
    if settings then
      for key, value in pairs(settings) do
        hs.settings.set(key, value)
      end
    end
  end
end

return module
