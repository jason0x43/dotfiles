---@meta

hs = {}

---@module 'user.types.hammerspoon.hs.fnutils'
hs.fnutils = fnutils

---@module 'user.types.hammerspoon.hs.mouse'
hs.mouse = mouse

---@module 'user.types.hammerspoon.hs.logger'
hs.logger = logger

---@module 'user.types.hammerspoon.hs.alert'
hs.alert = alert

---@module 'user.types.hammerspoon.hs.application'
hs.application = application

---@module 'user.types.hammerspoon.hs.drawing'
hs.drawing = drawing

---@module 'user.types.hammerspoon.hs.eventtap'
hs.eventtap = eventtap

---@module 'user.types.hammerspoon.hs.fs'
hs.fs = fs

---@module 'user.types.hammerspoon.hs.geometry'
hs.geometry = geometry

---@module 'user.types.hammerspoon.hs.hotkey'
hs.hotkey = hotkey

---@module 'user.types.hammerspoon.hs.http'
hs.http = http

---@module 'user.types.hammerspoon.hs.image'
hs.image = image

---@module 'user.types.hammerspoon.hs.json'
hs.json = json

---@module 'user.types.hammerspoon.hs.keycodes'
hs.keycodes = keycodes

---@module 'user.types.hammerspoon.hs.layout'
hs.layout = layout

---@module 'user.types.hammerspoon.hs.logger'
hs.logger = logger

---@module 'user.types.hammerspoon.hs.mouse'
hs.mouse = mouse

---@module 'user.types.hammerspoon.hs.pathwatcher'
hs.pathwatcher = pathwatcher

---@module 'user.types.hammerspoon.hs.screen'
hs.screen = screen

---@module 'user.types.hammerspoon.hs.settings'
hs.settings = settings

---@module 'user.types.hammerspoon.hs.spaces'
hs.spaces = spaces

---@module 'user.types.hammerspoon.hs.styledtext'
hs.styledtext = styledtext

---@module 'user.types.hammerspoon.hs.timer'
hs.timer = timer

---@module 'user.types.hammerspoon.hs.window'
hs.window = window

---Run a shell command, returning stdout as a string.
---@param command string command to execute
---@param with_user_env? boolean if true, execute command in interactive shell
---@return string output
---@return boolean status
---@return 'exit'|'signal' type
---@return integer rc
hs.execute = function(command, with_user_env) end

---@param variable any a lua variable
---@param options? {depth: number, newline: string, indent: string, process: fun(item, path): nil, metatables: boolean} a table of options
---@return string
hs.inspect = function(variable, options) end

---Reload the Hammerspoon config
---@return nil
hs.reload = function() end

hs.configdir = ''

return hs
