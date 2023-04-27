---@meta

---@class spaces
return {
  ---Returns the ID of the currently active space
  ---@param screen? integer|string|table optional screen to return active space for
  ---@return integer # ID of space being displayed
  activeSpaceOnScreen = function(screen) end,

  ---Returns the type of a space
  ---@param spaceId? integer the ID of a space
  ---@return 'user'|'fullscreen'|nil
  ---@return nil|string
  spaceType = function(spaceId) end,

  ---Gets the list of window IDs in a space
  ---@param spaceId? integer the ID of a space
  ---@return number[]
  windowsForSpace = function(spaceId) end,
}
