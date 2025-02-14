local M = {}

---Split a string at a delimiter
---@param str string
---@param delim string
---@return string[]
M.split = function(str, delim)
  ---@type string[]
  local parts = {}

  local start = 0
  while start < #str do
    local next = str:find(delim, start + 1)
    if next ~= nil then
      table.insert(parts, str:sub(start + 1, next - 1))
      start = next
    else
      table.insert(parts, str:sub(start + 1))
      break
    end
  end

  return parts
end

---Left-pad a string
---@param str string
---@param length integer
M.lpad = function(str, length)
  return string.rep(' ', length - #str) .. str
end

---Right-pad a string
---@param str string
---@param length integer
M.rpad = function(str, length)
  return str .. string.rep(' ', length - #str)
end

---Trim a string
---@param str string
M.trim = function(str)
  return str:gsub('^%s+', ''):gsub('%s+$', '')
end

return M
