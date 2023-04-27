---@meta

---@module 'alert'
---@module 'application'
---@module 'eventtap'
---@module 'geometry'
---@module 'hotkey'
---@module 'keycodes'
---@module 'logger'
---@module 'pathwatcher'
---@module 'spaces'
---@module 'window'

---@class hs
---@field alert alert
---@field application application
---@field eventtap eventtap
---@field geometry geometry
---@field hotkey hotkey
---@field keycodes keycodes
---@field logger logger
---@field pathwatcher pathwatcher
---@field spaces spaces
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
