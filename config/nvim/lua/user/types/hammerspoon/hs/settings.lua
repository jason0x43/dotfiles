---@meta

settings = {}

---Set a value
---@param key string
---@param val string | number | boolean | table | nil
---@return nil
settings.set = function(key, val) end

---Get a value
---@param key string
---@return string | number | boolean | table | nil
settings.get = function(key) end

return settings
