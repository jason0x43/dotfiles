---@meta

---@module 'hs.alert'
local alert
---@module 'hs.application'
local application
---@module 'hs.drawing'
local drawing
---@module 'hs.eventtap'
local eventtap
---@module 'hs.fs'
local fs
---@module 'hs.geometry'
local geometry
---@module 'hs.hotkey'
local hotkey
---@module 'hs.http'
local http
---@module 'hs.image'
local image
---@module 'hs.json'
local json
---@module 'hs.keycodes'
local keycodes
---@module 'hs.layout'
local layout
---@module 'hs.logger'
local logger
---@module 'hs.mouse'
local mouse
---@module 'hs.pathwatcher'
local pathwatcher
---@module 'hs.screen'
local screen
---@module 'hs.settings'
local settings
---@module 'hs.spaces'
local spaces
---@module 'hs.timer'
local timer
---@module 'hs.window'
local window

---@class hs
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
  reload = function() end,

  configdir = '',

  alert = alert,
  application = application,
  drawing = drawing,
  eventtap = eventtap,
  fs = fs,
  geometry = geometry,
  hotkey = hotkey,
  http = http,
  image = image,
  json = json,
  keycodes = keycodes,
  layout = layout,
  logger = logger,
  mouse = mouse,
  pathwatcher = pathwatcher,
  screen = screen,
  settings = settings,
  spaces = spaces,
  timer = timer,
  window = window,
}
