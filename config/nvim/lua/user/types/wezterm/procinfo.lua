---@meta

local procinfo = {}

---@param pid number
---@return string | nil
function procinfo.current_working_dir_for_pid(pid) end

---@param pid number
---@return string | nil
function procinfo.executable_path_for_pid(pid) end

---@param pid number
---@return _.wezterm.LocalProcessInfo | nil
function procinfo.get_info_for_pid(pid) end

---@return number
function procinfo.pid() end

return procinfo
