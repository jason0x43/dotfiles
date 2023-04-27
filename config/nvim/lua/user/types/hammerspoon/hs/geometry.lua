---@meta

---@class hs.geometry
---@field area number
---@field aspect hs.geometry
---@field bottomright hs.geometry
---@field center hs.geometry
---@field h number
---@field length number
---@field string number
---@field w number
---@field x number
---@field y number
local geometry = {}

---@class geometry
return {
  ---@return hs.geometry
  point = function(x, y) end,

  ---@return hs.geometry
  rect = function(x, y, w, h) end
}
