local wezterm = require("wezterm")
local util = require("user.util")

local M = {}

function M.get()
	return wezterm.GLOBAL.active_scheme
end

-- Save a wezterm scheme to a flat palette JSON file
function M.save(name, scheme)
	wezterm.GLOBAL.active_scheme = scheme

	local type = nil
	local variant = nil
	if name:find("(base16)") then
		type = "base16"
		variant = name:match("(.+) %(base16%)"):lower()
	elseif name:find("(selenized)") then
		type = "selenized"
		variant = name:match("Selenized (.+) %(selenized%)"):lower()
	elseif name:find("Catppuccin") then
		type = "catppuccin"
		variant = name:match("Catppuccin (%w+)"):lower()
	end

	if type == nil or variant == nil then
		error("Couldn't find type or variant for " .. name)
	end

	-- Create the scheme data that will be written to the theme file for other
	-- apps to use
	local scheme_json = {
		name = name,
		is_dark = util.is_dark(scheme.background),
		type = type,
		variant = variant,
	};

	for k, v in pairs(scheme) do
		scheme_json[tostring(k)] = v
	end

	local colors_file = wezterm.home_dir .. "/.local/share/wezterm/colors.json"
	util.save_json(scheme_json, colors_file)
end

return M
