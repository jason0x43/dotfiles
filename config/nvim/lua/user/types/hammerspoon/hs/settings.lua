---@meta

---@class settings
return {
  ---Set a value
  ---@param key string
  ---@param val string | number | boolean | table | nil
  ---@return nil
  set = function(key, val) end,

  ---Get a value
  ---@param key string
  ---@return string | number | boolean | table | nil
  get = function(key) end
}
