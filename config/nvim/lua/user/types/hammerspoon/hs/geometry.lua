---@meta

---@class hs.geometry.point
---@field x number
---@field y number

---@class hs.geometry.size
---@field w number
---@field h number

---@class hs.geometry.rect: hs.geometry.point, hs.geometry.size

---@class hs.geometry: hs.geometry.rect
---@field area number
---@field aspect hs.geometry
---@field bottomright hs.geometry
---@field center hs.geometry
---@field length number
---@field string number

---@class geometry
return {
  ---Create a new geometry object
  ---@return hs.geometry
  ---@overload fun(x: number, y: number, w: number, h: number): hs.geometry
  ---@overload fun(x: nil, y: nil, w: number, h: number): hs.geometry
  ---@overload fun(x: number, y: number): hs.geometry
  ---@overload fun(rect: {[1]: number, [2]: number, [3]: number, [4]: number}): hs.geometry
  ---@overload fun(point: {[1]: number, [2]: number}): hs.geometry
  ---@overload fun(rect: {x: number, y: number, w: number, h: number}): hs.geometry
  ---@overload fun(size: {w: number, h: number}): hs.geometry
  ---@overload fun(point: {x: number, y: number}): hs.geometry
  ---@overload fun(corners: {x1: number, y1: number, x2: number, y2: number}): hs.geometry
  ---@overload fun(hint: string): hs.geometry
  ---@overload fun(point: string, size: string): hs.geometry
  new = function(x, y, w, h) end,

  ---Create a point
  ---@param x number
  ---@param y number
  ---@return hs.geometry
  point = function(x, y) end,

  ---Create a rect
  ---@param x number
  ---@param y number
  ---@param w number
  ---@param h number
  ---@return hs.geometry
  rect = function(x, y, w, h) end,

  ---Create a size
  ---@param w number
  ---@param h number
  ---@return hs.geometry
  size = function(w, h) end,
}
