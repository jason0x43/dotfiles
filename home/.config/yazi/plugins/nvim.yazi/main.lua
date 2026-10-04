--- @since 25.5.31

---The type for the Url object
---@class (exact) Url

-- The type for the Cha object
---@class (exact) Cha
---@field is_dir boolean Whether the item is a directory.

---The type of the File object
---@class (exact) File
---@field url Url The Url of the file.
---@field cha Cha The Cha of the file.

---The type of the fs::File object
---@class (exact) fs.File: File
---@field is_hovered boolean Whether the file is hovered.

-- The type of a sync function
---@alias SyncFunction fun(...: any): any

-- The type of non table sendable values
---@alias SendableValueNonTable
---	|string
---	|number
---	|boolean
---	|nil
---	|Url

-- The type of sendable values
---@alias SendableValue
---	|SendableValueNonTable
---	|table<SendableValueNonTable, SendableValueNonTable|SendableValue>

---The type of the ya global
---@class (exact) Ya
---
--- Arguments:
---	- cmd: The command to emit.
---	- args: The arguments to pass to the command.
---@field emit fun(cmd: string, args: SendableValue): nil
---
--- Run a function in the sync context.
---@field sync fun(func: SyncFunction): SyncFunction
---
--- Sleep for a specified number of seconds.
--- Arguments:
---	- seconds: The number of seconds to sleep.
---@field sleep fun( seconds: number): nil

---The type of the tab::Folder object
---@class (exact) tab.Folder
---@field hovered fs.File|nil The hovered file of the folder.

---The type of the tab::Tab object
---@class (exact) tab.Tab
---@field current tab.Folder The current folder of the tab.

---The type of the app data
---@class (exact) Cx
---@field active tab.Tab The active tab.

---Type the cx global
---@type Cx
---@diagnostic disable-next-line: lowercase-global
cx = cx

---Type the ya global
---@type Ya
---@diagnostic disable-next-line: lowercase-global
ya = ya

local function setup(self, opts)
    opts = opts or {}
    self.open_multi = opts.open_multi
end

local get_hovered_path = ya.sync(function()
    local h = cx.active.current.hovered

    -- If there is no hovered item, exit the function
    if not h then
        return
    end

    return tostring(h.url)
end)

local hovered_is_dir = ya.sync(function()
    local h = cx.active.current.hovered

    -- If there is no hovered item, exit the function
    if not h then
        return false
    end

    return h.cha.is_dir
end)

local function entry(self)
    local h = get_hovered_path()
    if h == nil then
        return
    end

    local nvim = os.getenv("NVIM_SERVER")
    if nvim ~= nil then
        local lua_expr = "v:lua.vim.cmd.edit('" .. h .. "')"
        local cmd = "/opt/homebrew/bin/nvim --server "
            .. nvim
            .. ' --remote-expr "'
            .. lua_expr
            .. '"'
        ya.emit("shell", { cmd })
        ya.emit("quit", {})
    else
        local cmd = hovered_is_dir() and "enter" or "open"
        ya.emit(cmd, { hovered = not self.open_multi })
    end
end

return { entry = entry, setup = setup }
