local wezterm = require("wezterm")
local util = require("util")

local M = {}

function M.get()
	return wezterm.GLOBAL.active_scheme
end

-- Save a wezterm scheme to a flat palette JSON file
function M.save(name, scheme)
	wezterm.GLOBAL.active_scheme = scheme

	local type = "iterm2"
	if name:find("(base16)") then
		type = "base16"
	elseif name:find("(terminal.sexy)") then
		type = "terminal.sexy"
	elseif name:find("(Gogh)") then
		type = "gogh"
	elseif name:find("(selenized)") then
		type = "selenized"
	elseif name:find("(selenized)") then
		type = "selenized"
	end

	-- Create the scheme data that will be written to the theme file for other
	-- apps to use
	local scheme_json = {
		name = name,
		is_dark = util.is_dark(scheme.background),
		type = type,

		color00 = scheme.ansi[1],
		color01 = scheme.ansi[2],
		color02 = scheme.ansi[3],
		color03 = scheme.ansi[4],
		color04 = scheme.ansi[5],
		color05 = scheme.ansi[6],
		color06 = scheme.ansi[7],
		color07 = scheme.ansi[8],

		color08 = scheme.brights[1],
		color09 = scheme.brights[2],
		color10 = scheme.brights[3],
		color11 = scheme.brights[4],
		color12 = scheme.brights[5],
		color13 = scheme.brights[6],
		color14 = scheme.brights[7],
		color15 = scheme.brights[8],

		bg = scheme.background,
		fg = scheme.foreground,

		selection_bg = scheme.selection_bg,
	}

	if scheme.indexed ~= nil then
		for idx, color in pairs(scheme.indexed) do
			scheme_json["color" .. idx] = color
		end
	end

	local colors_file = wezterm.home_dir .. "/.local/share/wezterm/colors.json"
	util.save_json(scheme_json, colors_file)
end

return M
