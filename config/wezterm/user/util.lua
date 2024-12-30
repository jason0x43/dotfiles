---@type WezTerm
---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require("wezterm")
local io = require("io")

-- Trim a string
local function trim(str)
    return str:gsub("^%s*(.-)%s*$", "%1")
end

-- Run a command, return the output.
local function run(cmd)
    local _, stdout, stderr = wezterm.run_child_process(cmd)
    local out
    if stdout and stderr then
        out = stdout .. " " .. stderr
    elseif stdout then
        out = stdout
    else
        out = stderr
    end
    return trim(out)
end

local M = {
    run = run,
}

-- Return true if a file exists
local function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

-- Determine the brew command prefix
local _homebrew_base = nil
local function homebrew_base()
    if _homebrew_base == nil then
        local arch = run({ "arch" })
        _homebrew_base = "/opt/homebrew/bin"
        if arch == "i386" then
            _homebrew_base = "/usr/local/bin"
        end
    end
    return _homebrew_base
end

-- Find the given app in one of the standard locations
function M.find_app(name)
    local path = homebrew_base() .. "/" .. name
    if file_exists(path) then
        return path
    end

    path = "/usr/local/bin/" .. name
    if file_exists(path) then
        return path
    end

    path = "/usr/bin/" .. name
    if file_exists(path) then
        return path
    end

    return nil
end

-- Get the current system appearance
function M.get_appearance()
    if wezterm.gui.get_appearance():find("Dark") then
        return "dark"
    end
    return "light"
end

-- Indicate whether stage manager is active
function M.is_stage_manager_active()
    return M.run({
        "defaults",
        "read",
        "com.apple.WindowManager",
        "GloballyEnabled",
    }) == "1"
end

-- Merge two tables
function M.merge(table1, table2)
    for _, v in ipairs(table2) do
        table.insert(table1, v)
    end
    return table1
end

return M
