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

---Return the index of an item in a table, or nil if not found
---@param table any[]
---@param item any
---@return integer | nil
M.indexOf = function(table, item)
  for i, v in ipairs(table) do
    if v == item then
      return i
    end
  end
  return nil
end

---@param path string
---@return hs.image
M.loadImage = function(path)
	local img = hs.image.imageFromPath(path)
	if not img then
		error("Failed to load image from path: " .. path)
	end
	return img
end

return M
