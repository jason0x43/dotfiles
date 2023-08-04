module = {}

module.init = function(filename)
  if hs.fs.attributes(filename) then
    local secrets = hs.json.read(filename)
    if secrets then
      for key, value in pairs(secrets) do
        hs.settings.set(key, value)
      end
    end
  end
end

return module
