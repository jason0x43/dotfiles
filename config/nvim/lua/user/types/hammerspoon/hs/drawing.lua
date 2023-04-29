---@meta

---@class hs.drawing.color.rgb
---@field red number
---@field green number
---@field blue number
---@field alpha number
local RgbColor = {}

---@class hs.drawing.color.hsb
---@field hue number
---@field saturation number
---@field brightness number
---@field alpha number
local HsbColor = {}

---@class hs.drawing.color.hs
---@field list string
---@field name string
local HsColor = {}

---@class hs.drawing.color.html
---@field hex string
---@field alpha number
local HtmlColor = {}

---@class hs.drawing.color.image
---@field image hs.image
local ImageColor = {}

---@alias hs.drawing.color
---| hs.drawing.color.hs
---| hs.drawing.color.hsb
---| hs.drawing.color.rgb
---| hs.drawing.color.html
---| hs.drawing.color.image

---@class hs.drawing
local Drawing = {
  ---Destroy this drawing object
  ---@return nil
  delete = function() end,

  ---Set the stroke color of this object
  ---@param color hs.drawing.color
  ---@return hs.drawing
  setStrokeColor = function(self, color) end,

  ---Set whether or not to fill this object
  ---@param doFill boolean
  ---@return hs.drawing
  setFill = function(self, doFill) end,

  ---Set the stroke width of this object
  ---@param width number
  ---@return hs.drawing
  setStrokeWidth = function(self, width) end,

  ---Display this drawing object
  ---@return hs.drawing
  show = function() end,
}

---@class drawing
return {
  ---Create a new circle
  ---@param sizeRect hs.geometry a rect that contains the circle
  ---@return hs.drawing
  circle = function(sizeRect) end,
}
