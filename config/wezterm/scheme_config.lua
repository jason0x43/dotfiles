local wezterm = require("wezterm")
local util = require("util")

local scheme_file = wezterm.home_dir .. "/.local/share/wezterm/scheme.json"

local M = {}

-- Load a saved scheme config
function M.get()
	local data = util.load_json(scheme_file)
	if data ~= nil then
		if data.light ~= nil and data.dark ~= nil then
			return data
		end
	end

	return {
		light = "Selenized Light (selenized)",
		dark = "Selenized Black (selenized)",
		auto_switch = true,
	}
end

-- Save the current scheme name to a file
function M.save(cfg)
	cfg = cfg or M.get()
	util.save_json(cfg, scheme_file)
end

-- Save the current scheme name to a file
function M.update(props)
	local cfg = M.get()

	for key, val in pairs(props) do
		cfg[key] = val
	end

	M.save(cfg)
end

return M
