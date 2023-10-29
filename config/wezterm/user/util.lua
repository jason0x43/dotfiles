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
	trim = trim,
}

local homebrew_base = nil

-- Determine the brew command prefix
function M.homebrew_base()
	if homebrew_base == nil then
		local arch = run({ "arch" })
		homebrew_base = "/opt/homebrew/bin"
		if arch == "i386" then
			homebrew_base = "/usr/local/bin"
		end
	end
	return homebrew_base
end

-- Trim a string
function M.trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

-- Load JSON data from a file
function M.load_json(file)
	local f = assert(io.open(file, "r"))
	local text = assert(f:read("*a"))
	f:close()
	local ok, val = pcall(wezterm.json_parse, text)
	if not ok then
		print('Error parsing json')
		print(val)
		return nil
	end
	return val
end

-- Deep copy a table
local function deepcopy(tbl)
	if type(tbl) == 'table' then
		local copy = {}
		for k, v in pairs(tbl) do
			copy[tostring(k)] = deepcopy(v)
		end
		return copy
	end
	return tbl
end


-- Save JSON data a file
function M.save_json(data, file)
	local f = assert(io.open(file, "w"))
	f:write(wezterm.json_encode(deepcopy(data)))
	f:close()
end

-- Split a multiline string into a table
function M.splitlines(str)
	local lines = {}
	for s in str:gmatch("[^\r\n]+") do
		table.insert(lines, s)
	end
	return lines
end

-- Return true if a give color is dark
function M.is_dark(color)
	local bg = wezterm.color.parse(color)
	local _, _, l, _ = bg:hsla()
	return l < 0.5
end

-- Get the current system appearance
function M.get_appearance()
	if wezterm.gui.get_appearance():find("Dark") then
		return "dark"
	end
	return "light"
end

-- Return a list of all available scheme names
function M.get_schemes(window)
	local config = window:effective_config()
	local schemes = {}
	for name, scheme in pairs(config.color_schemes) do
		schemes[name] = scheme
	end
	return schemes
end

-- Return a list of all available scheme names
function M.get_scheme_names(window)
	local schemes = M.get_schemes(window)

	local scheme_names = {}
	for name, _ in pairs(schemes) do
		table.insert(scheme_names, name)
	end

	table.sort(scheme_names)

	return scheme_names
end

return M
