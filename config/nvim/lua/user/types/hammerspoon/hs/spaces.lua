---@meta

spaces = {}

  ---Returns the ID of the currently active space
  ---@param screen? integer|string|table optional screen to return active space for
  ---@return integer # ID of space being displayed
spaces.activeSpaceOnScreen = function(screen) end

  ---Return a table of all spaces for all screens
  ---@return table<string, string[]>
spaces.allSpaces = function() end

  ---Return the ID of the currently focused space
  ---@return integer
spaces.focusedSpace = function() end

  ---Go to a given space
  ---@param spaceId integer
  ---@return boolean | nil
  ---@return nil | string
spaces.gotoSpace = function(spaceId) end

  ---Move a window to a different space
  ---@param window integer|hs.window
  ---@param spaceID integer
  ---@param force? boolean
  ---@return true|nil
  ---@return nil|string
spaces.moveWindowToSpace = function(window, spaceID, force) end

  ---Return a table of all spaces for all screens
  ---@param screen? string|hs.screen
  ---@return integer[]|nil
  ---@return nil|string
spaces.spacesForScreen = function(screen) end

  ---Returns the type of a space
  ---@param spaceId? integer the ID of a space
  ---@return 'user'|'fullscreen'|nil
  ---@return nil|string
spaces.spaceType = function(spaceId) end

  ---Gets the list of window IDs in a space
  ---@param spaceId? integer the ID of a space
  ---@return number[]
spaces.windowsForSpace = function(spaceId) end

return spaces
