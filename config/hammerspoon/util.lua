local M = {}

---Return true if a list contains an item.
---@param list any[]
---@param value any
---@return boolean
M.contains = function(list, value)
  for _, v in ipairs(list) do
    if v == value then
      return true
    end
  end
  return false
end

---Trim whitespace from a string.
---@param str string
---@return string
M.trim = function(str)
  return str:match("^()%s*$") and "" or str:match("^%s*(.*%S)")
end

---Round a number to the nearest integer.
---@param num number
---@return integer
M.round = function(num)
  return math.floor(num + 0.5)
end

return M
