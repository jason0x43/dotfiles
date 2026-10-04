---@meta

local mux = {}

---@return _.wezterm.MuxDomain[]
function mux.all_domains() end

---@return _.wezterm.MuxWindow[]
function mux.all_windows() end

---@return string
function mux.get_active_workspace() end

---@param name_or_id string | number | nil
---@return _.wezterm.MuxDomain | nil
function mux.get_domain(name_or_id) end

---@param PANE_ID number
---@return _.wezterm.Pane | nil
function mux.get_pane(PANE_ID) end

---@param TAB_ID number
---@return _.wezterm.MuxTab | nil
function mux.get_tab(TAB_ID) end

---@param WINDOW_ID number
---@return _.wezterm.MuxWindow | nil
function mux.get_window(WINDOW_ID) end

---@return string[]
function mux.get_workspace_names() end

---@param old string
---@param new string
function mux.rename_workspace(old, new) end

---@param WORKSPACE string
function mux.set_active_workspace(WORKSPACE) end

---@param domain _.wezterm.MuxDomain
function mux.set_default_domain(domain) end

---@param opts { args: string[], cwd: string, set_environment_variables: table<string, string>, domain: { DomainName: string }, workspace: string[], position: { x: number, y: number, origin?: 'ScreenCoordinateSystem' | 'MainScreen' | 'ActiveScreen' | { Named: string } } }
---@return _.wezterm.MuxTab, _.wezterm.Pane, _.wezterm.MuxWindow
function mux.spawn_window(opts) end

return mux
