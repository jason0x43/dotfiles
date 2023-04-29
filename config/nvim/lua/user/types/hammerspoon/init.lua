---@meta

---@class hs
---@field alert alert
---@field application application
---@field drawing drawing
---@field eventtap eventtap
---@field geometry geometry
---@field hotkey hotkey
---@field image image
---@field keycodes keycodes
---@field layout layout
---@field logger logger
---@field mouse mouse
---@field pathwatcher pathwatcher
---@field screen screen
---@field spaces spaces
---@field timer timer
---@field window window
---@field configdir string
hs = {
  ---Run a shell command, returning stdout as a string.
  ---@param command string command to execute
  ---@param with_user_env? boolean if true, execute command in interactive shell
  ---@return string output
  ---@return boolean status
  ---@return 'exit'|'signal' type
  ---@return integer rc
  execute = function(command, with_user_env) end,

  ---@param variable any a lua variable
  ---@param options? {depth: number, newline: string, indent: string, process: fun(item, path): nil, metatables: boolean} a table of options
  ---@return string
  inspect = function(variable, options) end,

  ---Reload the Hammerspoon config
  ---@return nil
  reload = function() end
}
