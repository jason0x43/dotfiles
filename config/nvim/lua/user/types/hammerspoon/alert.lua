---@meta

---@class alert
return {
  ---Briefly show a message in large words in the middle of the screen
  ---@param str string|hs.styledtext the string or styledtext object to display
  ---@param style? table optional table containing style keys
  ---@param screen? hs.screen optional userdata object specifying display screen
  ---@param seconds? number number of seconds to display the alert
  show = function (str, style, screen, seconds) end
}
