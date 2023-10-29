---@meta

---@alias _.wezterm.ActionCallback fun(win: _.wezterm.Window, pane: _.wezterm.Pane, ...: any): (nil | false)
---@alias _.wezterm.AnsiColor 'Black' | 'Maroon' | 'Green' | 'Olive' | 'Navy' | 'Purple' | 'Teal' | 'Silver' | 'Grey' | 'Red' | 'Lime' | 'Yellow' | 'Blue' | 'Fuchsia' | 'Aqua' | 'White'
---@alias _.wezterm.Appearance 'Light' | 'Dark' | 'LightHighContrast' | 'DarkHighContrast'
---@alias _.wezterm.Clipboard 'Clipboard' | 'PrimarySelection' | 'ClipboardAndPrimarySelection'
---@alias _.wezterm.ColorSpec 'Default' | { AnsiColor: string } | { Color: string }
---@alias _.wezterm.CopyMode 'AcceptPattern' | 'ClearPattern' | 'ClearSelectionMode' | 'Close' | 'CycleMatchType' | 'EditPattern' | 'MoveBackwardSemanticZone' | { MoveBackwardSemanticZoneOfType: _.wezterm.SemanticZoneType } | 'MoveBackwardWord' | 'MoveDown' | 'MoveForwardSemanticZone' | { MoveForwardSemanticZoneOfType: _.wezterm.SemanticZoneType } | 'MoveForwardWord' | 'MoveForwardWordEnd' | 'MoveLeft' | 'MoveRight' | 'MoveToEndOfLineContent' | 'MoveToScrollbackBottom' | 'MoveToScrollbackTop' | 'MoveToSelectionOtherEnd' | 'MoveToSelectionOtherEndHoriz' | 'MoveToStartOfLine' | 'MoveToStartOfLineContent' | 'MoveToStartOfNextLine' | 'MoveToViewportBottom' | 'MoveToViewportMiddle' | 'MoveToViewportTop' | 'MoveUp' | 'NextMatch' | 'NextMatchPage' | 'PriorMatch' | 'PriorMatchPage' | { SetSelectionMode: _.wezterm.SelectionMode | 'SemanticZone' }
---@alias _.wezterm.CursorShape 'Default' | _.wezterm.CursorStyle
---@alias _.wezterm.CursorStyle 'BlinkingBlock' | 'SteadyBlock' | 'BlinkingUnderline' | 'SteadyUnderline' | 'BlinkingBar' | 'SteadyBar'
---@alias _.wezterm.CursorVisibility 'Hidden' | 'Visible'
---@alias _.wezterm.Direction 'Left' | 'Right' | 'Up' | 'Down' | 'Next' | 'Prev'
---@alias _.wezterm.EasingFunction 'Linear' | 'Ease' | 'EaseIn' | 'EaseInOut' | 'EaseOut' | { CubicBezier: number[] } | 'Constant'
---@alias _.wezterm.FreetypeLoadTarget 'Normal' | 'Light' | 'Mono' | 'HorizontalLcd'
---@alias _.wezterm.SelectionMode 'Cell' | 'Word' | 'Line' | 'Block'
---@alias _.wezterm.SemanticZoneType 'Prompt' | 'Input' | 'Output'
---@alias _.wezterm.Stretch 'UltraCondensed' | 'ExtraCondensed' | 'Condensed' | 'SemiCondensed' | 'Normal' | 'SemiExpanded' | 'Expanded' | 'ExtraExpanded' | 'UltraExpanded'
---@alias _.wezterm.Style 'Normal' | 'Italic' | 'Oblique'
---@alias _.wezterm.Weight 'Thin' | 'ExtraLight' | 'Light' | 'DemiLight' | 'Book' | 'Regular' | 'Medium' | 'DemiBold' | 'Bold' | 'ExtraBold' | 'Black' | 'ExtraBlack'

---@class _.wezterm.ScreenInformation
---@field name string
---@field x number
---@field y number
---@field height number
---@field width number
---@field max_fps? number

---@class _.wezterm.LocalProcessInfo
---@field pid number
---@field ppid number
---@field name string
---@field status 'Idle' | 'Run' | 'Sleep' | 'Stop' | 'Zombie' | 'Tracing' | 'Dead' | 'Wakekill' | 'Waking' | 'Parked' | 'LockBlocked' | 'Unknown'
---@field argv string[]
---@field executable string
---@field cwd string
---@field children table<number, _.wezterm.LocalProcessInfo>

---@class _.wezterm.KeyBindingBase
---@field key string
---@field action _.wezterm._Action

---@class _.wezterm.KeyBinding: _.wezterm.KeyBindingBase
---@field mods string

---@class _.wezterm.MouseEventInfo
---@field streak number
---@field button 'Left' | 'Right' | 'Middle' | { WheelDown: number } | { WheelUp: number }

---@class _.wezterm.MouseDownEvent
---@field Down _.wezterm.MouseEventInfo

---@class _.wezterm.MouseUpEvent
---@field Up _.wezterm.MouseEventInfo

---@class _.wezterm.MouseDragEvent
---@field Drag _.wezterm.MouseEventInfo

---@alias _.wezterm.MouseEvent _.wezterm.MouseDownEvent | _.wezterm.MouseUpEvent | _.wezterm.MouseDragEvent

---@class _.wezterm.MouseBindingBase
---@field event _.wezterm.MouseEvent
---@field action _.wezterm._Action
---@field mouse_reporting? boolean
---@field alt_screen? boolean | 'Any'

---@class _.wezterm.MouseBinding: _.wezterm.MouseBindingBase
---@field mods string

---@class _.wezterm.BatteryInfo
---@field state_of_charge number
---@field vendor string
---@field serial string
---@field time_to_full number | nil
---@field time_to_empty number | nil
---@field state 'Charging' | 'Discharging' | 'Empty' | 'Full' | 'Unknown'

---@class _.wezterm.HyperlinkRule
---@field regex string
---@field format string
---@field highlight? number

---@class _.wezterm.SshDomain
---@field name string
---@field remote_address string
---@field no_agent_auth? boolean
---@field username string
---@field connect_automatically? boolean
---@field timeout? number
---@field remote_wezterm_path? string
---@field ssh_option? table<string, any>
---@field multiplexing? 'WezTerm' | 'None'
---@field assume_shell? 'Unknown' | 'Posix'
---@field default_prog? string[]
---@field local_echo_threshold_ms? number

---@class _.wezterm.WslDomain
---@field name string
---@field distribution string
---@field username? string
---@field default_cwd? string
---@field default_prog? string[]

---@class _.wezterm.FontAttributes
---@field stretch? _.wezterm.Stretch
---@field style? _.wezterm.Style
---@field weight? _.wezterm.Weight

---@class _.wezterm.FontAttributesExtended: _.wezterm.FontAttributes
---@field family string
---@field harfbuzz_features? string[]
---@field freetype_load_target? _.wezterm.FreetypeLoadTarget
---@field freetype_render_target? _.wezterm.FreetypeLoadTarget
---@field freetype_load_flags? string
---@field assume_emoji_presentation? boolean

---@class _.wezterm.FontFallbackAttributesExtended: _.wezterm.FontAttributesExtended
---@field scale? number

---@class _.wezterm._Font

---@class _.wezterm.FormatAttribute
---@field Attribute { Underline: 'None' | 'Single' | 'Double' | 'Curly' | 'Dotted' | 'Dashed' } | { Intensity: 'Normal' | 'Bold' | 'Half' } | { Italic: boolean }

---@class _.wezterm.FormatForegroundColor
---@field Foreground { AnsiColor: _.wezterm.AnsiColor } | { Color: string }

---@class _.wezterm.FormatBackgroundColor
---@field Background { AnsiColor: _.wezterm.AnsiColor } | { Color: string }

---@alias _.wezterm.FormatItem _.wezterm.FormatAttribute | _.wezterm.FormatForegroundColor | _.wezterm.FormatBackgroundColor | { Text: string } | 'ResetAttributes'

---@class _.wezterm.SpawnCommand
---@field label? string
---@field args? string[]
---@field cwd? string
---@field set_environment_variables? table<string, string>
---@field domain? 'CurrentPaneDomain' | 'DefaultDomain' | { DomainName: string }
---@field position? { x: number, y: number, origin?: 'ScreenCoordinateSystem' | 'MainScreen' | 'ActivateScreen' | { Named: string } }

---@class _.wezterm.Color
local Color = {}

---@param degrees number
---@return _.wezterm.Color
function Color:adjust_hue_fixed(degrees) end

---@param degrees number
---@return _.wezterm.Color
function Color:adjust_hue_fixed_ryb(degrees) end

---@return _.wezterm.Color
function Color:complement() end

---@return _.wezterm.Color
function Color:complement_ryb() end

---@param color _.wezterm.Color
---@return number
function Color:contrast_ratio(color) end

---@param factor number
---@return _.wezterm.Color
function Color:darken(factor) end

---@param amount number
---@return _.wezterm.Color
function Color:darken_fixed(amount) end

---@param color _.wezterm.Color
---@return number
function Color:delta_e(color) end

---@param factor number
---@return _.wezterm.Color
function Color:desaturate(factor) end

---@param amount number
---@return _.wezterm.Color
function Color:desaturate_fixed(amount) end

---@return number, number, number, number
function Color:hsla() end

---@return number, number, number, number
function Color:laba() end

---@param factor number
---@return _.wezterm.Color
function Color:lighten(factor) end

---@param amount number
---@return _.wezterm.Color
function Color:lighten_fixed(amount) end

---@return number, number, number, number
function Color:linear_rgba() end

---@param factor number
---@return _.wezterm.Color
function Color:saturate(factor) end

---@param amount number
---@return _.wezterm.Color
function Color:saturate_fixed(amount) end

---@return _.wezterm.Color, _.wezterm.Color, _.wezterm.Color
function Color:square() end

---@return number, number, number, number
function Color:srgba_u8() end

---@return _.wezterm.Color, _.wezterm.Color
function Color:triad() end

---@class _.wezterm.TabBarColor
---@field bg_color string
---@field fg_color string
---@field intensity 'Half' | 'Normal' | 'Bold'
---@field italic boolean
---@field strikethrough boolean
---@field underline 'None' | 'Single' | 'Double'

---@class _.wezterm.TabBarColors
---@field active_tab? _.wezterm.TabBarColor
---@field background? string
---@field inactive_tab? _.wezterm.TabBarColor
---@field inactive_tab_edge? string
---@field inactive_tab_edge_hover? string
---@field inactive_tab_hover? _.wezterm.TabBarColor
---@field new_tab? _.wezterm.TabBarColor
---@field new_tab_hover? _.wezterm.TabBarColor

---@class _.wezterm.TabBarStyle
---@field active_tab_left? string
---@field active_tab_right? string
---@field inactive_tab_left? string
---@field inactive_tab_right? string
---@field inactive_tab_hover_left? string
---@field inactive_tab_hover_right? string
---@field new_tab_left? string
---@field new_tab_right? string
---@field new_tab_hover_left? string
---@field new_tab_hover_right? string
---@field window_hide? string
---@field window_hide_hover? string
---@field window_maximize? string
---@field window_maximize_hover? string
---@field window_close? string
---@field window_close_hover? string

---@class _.wezterm.Palette
---@field ansi? string[]
---@field background? string
---@field brights? string[]
---@field cursor_bg? string
---@field cursor_border? string
---@field cursor_fg? string
---@field foreground? string
---@field indexed? table<number, string>
---@field selection_bg? string
---@field selection_fg? string
---@field tab_bar? _.wezterm.TabBarColors
---@field scrollbar_thumb? string
---@field split? string
---@field visual_bell? string
---@field compose_cursor? string
---@field copy_mode_active_highlight_fg? _.wezterm.ColorSpec
---@field copy_mode_active_highlight_bg? _.wezterm.ColorSpec
---@field copy_mode_inactive_highlight_fg? _.wezterm.ColorSpec
---@field copy_mode_inactive_highlight_bg? _.wezterm.ColorSpec
---@field quick_select_label_fg? _.wezterm.ColorSpec
---@field quick_select_label_bg? _.wezterm.ColorSpec
---@field quick_select_match_fg? _.wezterm.ColorSpec
---@field quick_select_match_bg? _.wezterm.ColorSpec

---@class _.wezterm.ColorSchemeMetaData
---@field name? string
---@field author? string
---@field origin_url? string
---@field wezterm_version? string
---@field aliases? string[]

---@class _.wezterm.SemanticZone
---@field start_y number
---@field start_x number
---@field end_y number
---@field end_x number
---@field semantic_type _.wezterm.SemanticZoneType

---@class _.wezterm.PresetGradient
---@field preset 'Blues' | 'BrBg' | 'BuGn' | 'BuPu' | 'Cividis' | 'Cool' | 'CubeHelixDefault' | 'GnBu' | 'Greens' | 'Greys' | 'Inferno' | 'Magma' | 'OrRd' | 'Oranges' | 'PiYg' | 'Plasma' | 'PrGn' | 'PuBu' | 'PuBuGn' | 'PuOr' | 'PuRd' | 'Purples' | 'Rainbow' | 'RdBu' | 'RdGy' | 'RdPu' | 'RdYlBu' | 'RdYlGn' | 'Reds' | 'Sinebow' | 'Spectral' | 'Turbo' | 'Viridis' | 'Warm' | 'YlGn' | 'YlGnBu' | 'YlOrBr' | 'YlOrRd'

---@class _.wezterm.LinearGradientOrientation
---@field angle number

---@class _.wezterm.RadialGradientOrientation
---@field radius? number
---@field cx? number
---@field cy? number

---@class _.wezterm.Gradient
---@field colors string[]
---@field orientation? 'Horizontal' | 'Vertical' | { Linear: _.wezterm.LinearGradientOrientation } | { Radial: _.wezterm.RadialGradientOrientation }
---@field interpolation? 'Linear' | 'Basis' | 'CatmullRom'
---@field blend? 'Rgb' | 'LinearRgb' | 'Hsv' | 'Oklab'
---@field noise? number
---@field segment_size? number
---@field segment_smoothness? number

---@alias _.wezterm.BackgroundSource { File: string | { path: string, speed: number } } | _.wezterm.Gradient | { Color: string }

---@class _.wezterm.HsbTransform
---@field hue? number
---@field saturation? number
---@field brightness? number

---@class _.wezterm.BackgroundLayer
---@field source _.wezterm.BackgroundSource
---@field attachment? 'Fixed' | 'Scroll' | { Parallax: number }
---@field repeat_x? 'Repeat' | 'Mirror' | 'NoRepeat'
---@field repeat_x_size? number | string
---@field repeat_y? 'Repeat' | 'Mirror' | 'NoRepeat'
---@field repeat_y_size? number | string
---@field vertical_align? 'Top' | 'Middle' | 'Bottom'
---@field vertical_offset? number | string
---@field horizontal_align? 'Left' | 'Center' | 'Right'
---@field horizontal_offset? number | string
---@field opacity? number
---@field hsb? _.wezterm.HsbTransform
---@field height? 'Cover' | 'Contain' | number | string
---@field width? 'Cover' | 'Contain' | number | string

---@class _.wezterm.TlsDomainClient
---@field name string
---@field bootstrap_via_ssh string
---@field remote_address string
---@field pem_private_key? string
---@field pem_cert? string
---@field pem_ca? string
---@field pem_root_certs? string[]
---@field accept_invalid_hostnames? boolean
---@field expected_cn? string
---@field connect_automatically? boolean
---@field read_timeout? number
---@field write_timeout? number
---@field remote_wezterm_path? string

---@class _.wezterm.TlsDomainServer
---@field bind_address string
---@field pem_private_key? string
---@field pem_cert? string
---@field pem_ca? string
---@field pem_root_certs? string[]

---@class _.wezterm.MultiplexerDomain
---@field name string
---@field socket_path? string
---@field no_serve_automatically? boolean
---@field skip_permissions_check? boolean

---@class _.wezterm.VisualBellConfig
---@field fade_in_duration_ms? number
---@field fade_out_duration_ms? number
---@field fade_in_function? _.wezterm.EasingFunction
---@field fade_out_function? _.wezterm.EasingFunction
---@field target? 'BackgroundColor' | 'CursorColor'

---@class _.wezterm.GpuInfo
---@field backend string
---@field device number
---@field device_type string
---@field driver? string
---@field driver_info? string
---@field name string
---@field vendor number

---@class _.wezterm.WindowFrame
---@field font _.wezterm._Font
---@field font_size number
---@field inactive_titlebar_bg? string
---@field active_titlebar_bg? string
---@field inactive_titlebar_fg? string
---@field active_titlebar_fg? string
---@field inactive_titlebar_border_bottom? string
---@field active_titlebar_border_bottom? string
---@field button_fg? string
---@field button_bg? string
---@field button_hover_fg? string
---@field button_hover_bg? string
---@field border_left_width? number | string
---@field border_right_width? number | string
---@field border_bottom_height? number | string
---@field border_top_height? number | string
---@field border_left_color? string
---@field border_right_color? string
---@field border_bottom_color? string
---@field border_top_color? string

---@class _.wezterm.WindowPadding
---@field left? number
---@field right? number
---@field top? number
---@field bottom? number

---@class _.wezterm.Pane
local Pane = {}

---@return nil
function Pane:activate() end

---@return string | nil
function Pane:get_current_working_dir() end

---@return { x: number, y: number, shape: _.wezterm.CursorShape, visibility: _.wezterm.CursorVisibility }
function Pane:get_cursor_position() end

---@return { cols: number, viewport_rows: number, scrollback_rows: number, physical_top: number, scrollback_top: number }
function Pane:get_dimensions() end

---@return string | nil
function Pane:get_domain_name() end

---@return _.wezterm.LocalProcessInfo | nil
function Pane:get_foreground_process_info() end

---@return string | nil
function Pane:get_foreground_process_name() end

---@param nlines? number
---@return string
function Pane:get_lines_as_text(nlines) end

---@param nlines? number
---@return string
function Pane:get_logical_lines_as_text(nlines) end

---@return { password_input?: boolean, is_tardy?: boolean, since_last_response_time?: number } | nil
function Pane:get_metadata() end

---@param x number
---@param y number
---@return _.wezterm.SemanticZone | nil
function Pane:get_semantic_zone_at(x, y) end

---@param zone_type _.wezterm.SemanticZoneType
---@return _.wezterm.SemanticZone[]
function Pane:get_semantic_zones(zone_type) end

---@param start_x number
---@param start_y number
---@param end_x number
---@param end_y number
---@return string
function Pane:get_text_from_region(start_x, start_y, end_x, end_y) end

---@param zone _.wezterm.SemanticZone
---@return string
function Pane:get_text_from_semantic_zone(zone) end

---@return string
function Pane:get_title() end

---@return string
function Pane:get_tty_name() end

---@return table<string, any>
function Pane:get_user_vars() end

---@return boolean
function Pane:has_unseen_output() end

---@param text string
function Pane:inject_output(text) end

---@return boolean
function Pane:is_alt_screen_active() end

---@return _.wezterm.MuxTab, _.wezterm.MuxWindow
function Pane:move_to_new_tab() end

---@param workspace? string
---@return _.wezterm.MuxTab, _.wezterm.MuxWindow
function Pane:move_to_new_window(workspace) end

---@return _.wezterm.Pane
function Pane:mux_pane() end

---@return number
function Pane:pane_id() end

---@param text string
function Pane:paste(text) end

---@param text string
function Pane:send_paste(text) end

---@param text string
function Pane:send_text(text) end

---@param opts { args: string[], cwd: string; set_environment_variables: table<string, string>, domain: 'DefaultDomain' | { DomainName: string }, direction: 'Right' | 'Left' | 'Up' | 'Down', top_level: boolean, size: number }
---@return _.wezterm.Pane
function Pane:split(opts) end

---@return _.wezterm.MuxTab
function Pane:tab() end

---@return _.wezterm.MuxWindow
function Pane:window() end

---@class _.wezterm.MuxDomain
local MuxDomain = {}

function MuxDomain:attach() end
function MuxDomain:detach() end

---@return number
function MuxDomain:domain_id() end

---@return boolean
function MuxDomain:has_any_panes() end

---@return boolean
function MuxDomain:is_spawnable() end

---@return string
function MuxDomain:label() end

---@return string
function MuxDomain:name() end

---@return 'Attached' | 'Detached'
function MuxDomain:state() end

---@class _.wezterm.TabWthInfo
---@field index number
---@field is_active boolean
---@field tab _.wezterm.MuxTab

---@class _.wezterm.PaneInformation
---@field pane_id integer
---@field pane_index integer
---@field is_active boolean
---@field is_zoomed boolean
---@field left integer
---@field top integer
---@field width integer
---@field height integer
---@field pixel_width integer
---@field pixel_height integer
---@field title string
---@field user_vars table<string, any>

---@class _.wezterm.TabInformation
---@field tab_id integer
---@field tab_index integer
---@field is_active boolean
---@field active_pane _.wezterm.PaneInformation
---@field window_id integer
---@field window_title string
---@field tab_title string

---@class _.wezterm.MuxWindow
local MuxWindow = {}

---@return _.wezterm.Pane | nil
function MuxWindow:active_pane() end

---@return _.wezterm.MuxTab | nil
function MuxWindow:active_tab() end

---@return string
function MuxWindow:get_title() end

---@return string
function MuxWindow:get_workspace() end

---@return _.wezterm.Window | nil
function MuxWindow:gui_window() end

---@param TITLE string
function MuxWindow:set_title(TITLE) end

---@param workspace string
function MuxWindow:set_workspace(workspace) end

---@param opts { args: string[], cwd: string, set_environment_variables: table<string, string>, domain: { DomainName: string } }
---@return _.wezterm.MuxTab, _.wezterm.Pane, _.wezterm.MuxWindow
function MuxWindow:spawn_tab(opts) end

---@return _.wezterm.MuxTab[]
function MuxWindow:tabs() end

---@return _.wezterm.TabWthInfo[]
function MuxWindow:tabs_with_info() end

---@return number
function MuxWindow:window_id() end

---@class _.wezterm.PaneWithInfo
---@field index number
---@field is_active boolean
---@field is_zoomed boolean
---@field left number
---@field top number
---@field width number
---@field height number
---@field pixel_width number
---@field pixel_height number
---@field pane _.wezterm.Pane

---@class _.wezterm.MuxTab
local MuxTab = {}

function MuxTab:activate() end

---@return _.wezterm.Pane | nil
function MuxTab:active_pane() end

---@param direction _.wezterm.Direction
---@return _.wezterm.Pane
function MuxTab:get_pane_direction(direction) end

---@return { rows: number, cols: number, pixel_width: number, pixel_height: number, dpi: number }
function MuxTab:get_size() end

---@return string
function MuxTab:get_title() end

---@return _.wezterm.Pane[]
function MuxTab:panes() end

---@return _.wezterm.PaneWithInfo[]
function MuxTab:panes_with_info() end

function MuxTab:rotate_clockwise() end
function MuxTab:rotate_counter_clockwise() end

---@param TITLE string
function MuxTab:set_title(TITLE) end

---@param bool boolean
---@return boolean
function MuxTab:set_zoomed(bool) end

---@return number
function MuxTab:tab_id() end

---@return _.wezterm.MuxWindow | nil
function MuxTab:window() end

---@class _.wezterm.Time
local Time = {}

---@param format string
---@return string
function Time:format(format) end

---@param format string
---@return string
function Time:format_utc(format) end

---@param lat number
---@param lon number
---@return { progression: number, rise: _.wezterm.Time, set: _.wezterm.Time, up: boolean }
function Time:sun_times(lat, lon) end

---@class _.wezterm.Window
local Window = {}

---@return string | nil
function Window:active_key_table() end

---@return _.wezterm.Pane
function Window:active_pane() end

---@return _.wezterm.MuxTab
function Window:active_tab() end

---@return string
function Window:active_workspace() end

---@return string | nil
function Window:composition_status() end

---@param text string
---@param clipboard? _.wezterm.Clipboard
function Window:copy_to_clipboard(text, clipboard) end

---@return _.wezterm.MouseEvent
function Window:current_event() end

---@return any
function Window:effective_config() end

function Window:focus() end

---@return _.wezterm.Appearance
function Window:get_appearance() end

---@return any
function Window:get_config_overrides() end

---@return { pixel_width: number, pixel_height: number, dpi: number, is_full_screen: boolean }
function Window:get_dimensions() end

---@param pane _.wezterm.Pane
---@return string
function Window:get_selection_escapes_for_pane(pane) end

---@param pane _.wezterm.Pane
---@return string
function Window:get_selection_text_for_pane(pane) end

---@return boolean
function Window:is_focused() end

---@return string, string
function Window:keyboard_modifiers() end

---@return boolean
function Window:leader_is_active() end

function Window:maximize() end

---@return _.wezterm.MuxWindow
function Window:mux_window() end

---@param key_assignment _.wezterm._Action
---@param pane _.wezterm.Pane
function Window:get_selection_text_for_pane(key_assignment, pane) end

---@param key_assignment _.wezterm._Action
---@param pane _.wezterm.Pane
function Window:perform_action(key_assignment, pane) end

function Window:restore() end

---@param overrides any
function Window:set_config_overrides(overrides) end

---@param width number
---@param height number
function Window:set_inner_size(width, height) end

---@param status string
function Window:set_left_status(status) end

---@param x number
---@param y number
function Window:set_position(x, y) end

---@param status string
function Window:set_right_status(status) end

---@param title string
---@param message string
---@param url? string | nil
---@param timeout_milliseconds? number
function Window:toast_notification(
  title,
  message,
  url,
  timeout_milliseconds
)
end

function Window:toggle_fullscreen() end

---@return number
function Window:window_id() end

---@class _.wezterm._KeyAssignmentAction
---@class _.wezterm._CallbackAction

---@alias _.wezterm._Action _.wezterm._KeyAssignmentAction | _.wezterm._CallbackAction

---@class _.wezterm.KeyAssignment
---@field ActivateCommandPalette _.wezterm._KeyAssignmentAction
---@field ActivateCopyMode _.wezterm._KeyAssignmentAction
---@field ActivateLastTab _.wezterm._KeyAssignmentAction
---@field ClearKeyTableStack _.wezterm._KeyAssignmentAction
---@field ClearSelection _.wezterm._KeyAssignmentAction
---@field DecreaseFontSize _.wezterm._KeyAssignmentAction
---@field DisableDefaultAssignment _.wezterm._KeyAssignmentAction
---@field Hide _.wezterm._KeyAssignmentAction
---@field HideApplication _.wezterm._KeyAssignmentAction
---@field IncreaseFontSize _.wezterm._KeyAssignmentAction
---@field Nop _.wezterm._KeyAssignmentAction
---@field OpenLinkAtMouseCursor _.wezterm._KeyAssignmentAction
---@field PopKeyTable _.wezterm._KeyAssignmentAction
---@field QuickSelect _.wezterm._KeyAssignmentAction
---@field QuitApplication _.wezterm._KeyAssignmentAction
---@field ReloadConfiguration _.wezterm._KeyAssignmentAction
---@field ResetFontAndWindowSize _.wezterm._KeyAssignmentAction
---@field ResetFontSize _.wezterm._KeyAssignmentAction
---@field ResetTerminal _.wezterm._KeyAssignmentAction
---@field ScrollByCurrentEventWheelDelta _.wezterm._KeyAssignmentAction
---@field ScrollToBottom _.wezterm._KeyAssignmentAction
---@field ScrollToTop _.wezterm._KeyAssignmentAction
---@field Show _.wezterm._KeyAssignmentAction
---@field ShowDebugOverlay _.wezterm._KeyAssignmentAction
---@field ShowLauncher _.wezterm._KeyAssignmentAction
---@field ShowTabNavigator _.wezterm._KeyAssignmentAction
---@field SpawnWindow _.wezterm._KeyAssignmentAction
---@field StartWindowDrag _.wezterm._KeyAssignmentAction
---@field ToggleFullScreen _.wezterm._KeyAssignmentAction
---@field TogglePaneZoomState _.wezterm._KeyAssignmentAction
local KeyAssignment = {}

---@param opts { name: string, timeout_milliseconds?: number, one_shot?: boolean, replace_current?: boolean, until_unknown?: boolean, prevent_fallback?: boolean }
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ActivateKeyTable(opts) end

---@param index number
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ActivatePaneByIndex(index) end

---@param direction 'Left' | 'Right' | 'Up' | 'Down' | 'Next' | 'Prev'
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ActivatePaneDirection(direction) end

---@param tab number
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ActivateTab(tab) end

---@param tab number
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ActivateTabRelative(tab) end

---@param tab number
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ActivateTabRelativeNoWrap(tab) end

---@param window number
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ActivateWindow(window) end

---@param window number
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ActivateWindowRelative(window) end

---@param window number
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ActivateWindowRelativeNoWrap(window) end

---@param size_direction ('Left' | 'Down' | 'Up' | 'Right' | number)[]
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.AdjustPaneSize(size_direction) end

---@param domain string
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.AttachDomain(domain) end

---@class _.wezterm.CharSelectOpts
---@field copy_on_select? boolean
---@field copy_to? _.wezterm.Clipboard
---@field group? 'RecentlyUsed' | 'SmileysAndEmotion' | 'PeopleAndBody' | 'AnimalsAndNature' | 'FoodAndDrink' | 'TravelAndPlaces' | 'Activities' | 'Objects' | 'Symbols' | 'Flags' | 'NerdFonts' | 'UnicodeNames'

---@param opts _.wezterm.CharSelectOpts
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.CharSelect(opts) end

---@param mode 'ScrollbackOnly' | 'ScrollbackAndViewport'
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ClearScrollback(mode) end

---@param opts { confirm: boolean }
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.CloseCurrentPane(opts) end

---@param opts { confirm: boolean }
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.CloseCurrentTab(opts) end

---@param copy_to _.wezterm.Clipboard
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.CompleteSelection(copy_to) end

---@param copy_to _.wezterm.Clipboard
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.CompleteSelectionOrOpenLinkAtMouseCursor(copy_to) end

---@param copy_to _.wezterm.Clipboard
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.CopyTo(copy_to) end

---@param mode _.wezterm.CopyMode
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.CopyMode(mode) end

---@param domain 'CurrentPaneDomain' | { DomainName: string }
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.DetachDomain(domain) end

---@param event string
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.EmitEvent(event) end

---@param mode _.wezterm.SelectionMode
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ExtendSelectionToMouseCursor(mode) end

---@param opts { title: string, choices: { id: string, label: string }[], action: _.wezterm._CallbackAction }
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.InputSelector(opts) end

---@param index number
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.MoveTab(index) end

---@param index number
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.MoveTabRelative(index) end

---@param actions _.wezterm._Action[]
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.Multiple(actions) end

---@param opts { mode?: 'Activate' | 'SwapWithActive', alphabet?: string }
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.PaneSelect(opts) end

---@param source 'Clipboard' | 'PrimarySelection'
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.PasteFrom(source) end

---@param opts { description: string, action: _.wezterm._CallbackAction }
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.PromptInputLine(opts) end

---@param args { patterns?: string[], alphabet?: string, action?: _.wezterm._Action, label?: string, scope_lines?: number }
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.QuickSelectArgs(args) end

---@param direction 'Clockwise' | 'CounterClockwise'
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.RotatePanes(direction) end

---@param direction number
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ScrollByLine(direction) end

---@param direction number
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ScrollByPage(direction) end

---@param direction number
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ScrollToPrompt(direction) end

---@param pattern { Regex: string } | { CaseSensitiveString: string } | { CaseInSensitiveString: string }
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.Search(pattern) end

---@param mode _.wezterm.SelectionMode | 'SemanticZone'
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.SelectTextAtMouseCursor(mode) end

---@param key { key: string, mods: string }
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.SendKey(key) end

---@param string string
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.SendString(string) end

---@param state boolean
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.SetPaneZoomState(state) end

---@param args { flags: string, title?: string }
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.ShowLauncherArgs(args) end

---@param args _.wezterm.SpawnCommand
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.SpawnCommandInNewTab(args) end

---@param args _.wezterm.SpawnCommand
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.SpawnCommandInNewWindow(args) end

---@param domain 'CurrentPaneDomain' | 'DefaultDomain' | { DomainName: string }
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.SpawnTab(domain) end

---@param args _.wezterm.SpawnCommand
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.SplitHorizontal(args) end

---@param args { direction: 'Up' | 'Down' | 'Left' | 'Right', size?: { Cells: number } | { Percent: number }, command?: _.wezterm.SpawnCommand, top_level?: boolean }
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.SplitPane(args) end

---@param args _.wezterm.SpawnCommand
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.SplitVertical(args) end

---@param args { name?: string, command?: _.wezterm.SpawnCommand }
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.SwitchToWorkspace(args) end

---@param direction number
---@return _.wezterm._KeyAssignmentAction
function KeyAssignment.SwitchWorkspaceRelative(direction) end

---@class _.wezterm.ConfigBuilder
---@field adjust_window_size_when_changing_font_size boolean
---@field allow_square_glyphs_to_overflow_width 'WhenFollowedBySpace' | 'Always' | 'Never'
---@field allow_win32_input_mode boolean
---@field alternate_buffer_wheel_scroll_speed number
---@field animation_fps number
---@field audible_bell 'SystemBeep' | 'Disabled'
---@field automatically_reload_config boolean
---@field background _.wezterm.BackgroundLayer[]
---@field bold_brightens_ansi_colors boolean | 'No' | 'BrightAndBold' | 'BrightOnly'
---@field bypass_mouse_reporting_modifiers string
---@field canonicalize_pasted_newlines boolean | 'None' | 'LineFeed' | 'CarriageReturn' | 'CarriageReturnAndLineFeed'
---@field cell_width number
---@field check_for_updates boolean
---@field check_for_updates_interval_seconds number
---@field clean_exit_codes number[]
---@field color_scheme string
---@field color_schemes table<string, _.wezterm.Palette>
---@field colors _.wezterm.Palette
---@field command_palette_bg_color string
---@field command_palette_fg_color string
---@field command_palette_font_size number
---@field cursor_blink_ease_in _.wezterm.EasingFunction
---@field cursor_blink_ease_out _.wezterm.EasingFunction
---@field cursor_blink_rate number
---@field cursor_thickness number | string
---@field custom_block_glyphs boolean
---@field daemon_options { pid_file?: string, stdout?: string, stderr?: string }
---@field debug_key_events boolean
---@field default_cursor_style _.wezterm.CursorStyle
---@field default_cwd string
---@field default_domain 'local' | string
---@field default_gui_startup_args string[]
---@field default_prog string[]
---@field default_workspace 'default' | string
---@field detect_password_input boolean
---@field disable_default_key_bindings boolean
---@field disable_default_mouse_bindings boolean
---@field disable_default_quick_select_patterns boolean
---@field display_pixel_geometry 'RGB' | 'BGR'
---@field dpi number
---@field enable_csi_u_key_encoding boolean
---@field enable_kitty_keyboard boolean
---@field enable_scroll_bar boolean
---@field enable_tab_bar boolean
---@field enable_wayland boolean
---@field exit_behavior 'Close' | 'Hold' | 'CloseOnCleanExit'
---@field font _.wezterm._Font
---@field font_dirs string[]
---@field font_locator? 'ConfigDirsOnly'
---@field font_rasterizer 'FreeType'
---@field font_rules any[]
---@field font_shaper 'Harfbuzz'
---@field font_size number
---@field force_reverse_video_cursor boolean
---@field foreground_text_hsb _.wezterm.HsbTransform
---@field freetype_interpreter_version 35 | 38 | 40
---@field freetype_load_flags string
---@field freetype_load_target _.wezterm.FreetypeLoadTarget
---@field freetype_pcf_long_family_names boolean
---@field freetype_render_target string
---@field front_end 'OpenGL' | 'Software' | 'WebGpu'
---@field harfbuzz_features string[]
---@field hide_mouse_cursor_when_typing boolean
---@field hide_tab_bar_if_only_one_tab boolean
---@field hyperlink_rules _.wezterm.HyperlinkRule[]
---@field ime_preedit_rendering 'Builtin' | 'System'
---@field inactive_pane_hsb _.wezterm.HsbTransform
---@field initial_cols number
---@field initial_rows number
---@field integrated_title_button_alignment 'Left' | 'Right'
---@field integrated_title_button_color 'Auto' | string
---@field integrated_title_button_style 'Windows' | 'Gnome' | 'MacOsNative'
---@field integrated_title_buttons ('Hide' | 'Maximize' | 'Close')[]
---@field key_map_preference 'Mapped' | 'Physical'
---@field key_tables table<string, _.wezterm.KeyBinding[]>
---@field keys _.wezterm.KeyBinding[]
---@field launch_menu _.wezterm.SpawnCommand[]
---@field line_height number
---@field log_unknown_escape_sequences boolean
---@field macos_forward_to_ime_modifier_mask string
---@field macos_window_background_blur number
---@field max_fps number
---@field min_scroll_bar_height number | string
---@field mouse_bindings _.wezterm.MouseBinding[]
---@field mouse_wheel_scrolls_tabs boolean
---@field mux_env_remove string[]
---@field native_macos_fullscreen_mode boolean
---@field normalize_output_to_unicode_nfc boolean
---@field pane_focus_follows_mouse boolean
---@field prefer_egl boolean
---@field quick_select_alphabet string
---@field quick_select_patterns string[]
---@field quit_when_all_windows_are_closed boolean
---@field quote_dropped_files 'None' | 'SpacesOnly' | 'Posix' | 'Windows' | 'WindowsAlwaysQuoted'
---@field scroll_to_bottom_on_input boolean
---@field scrollback_lines number
---@field selection_word_boundary string
---@field send_composed_key_when_left_alt_is_pressed boolean
---@field send_composed_key_when_right_alt_is_pressed boolean
---@field serial_ports { name: string, port?: string, baud?: number }[]
---@field set_environment_variables table<string, string>
---@field show_new_tab_button_in_tab_bar boolean
---@field show_tab_index_in_tab_bar boolean
---@field show_tabs_in_tab_bar boolean
---@field show_update_window boolean
---@field skip_close_confirmation_for_processes_named string[]
---@field ssh_backend 'Ssh2' | 'LibSsh'
---@field ssh_domains _.wezterm.SshDomain[]
---@field status_update_interval number
---@field strikethrough_position number | string
---@field swallow_mouse_click_on_pane_focus boolean
---@field swallow_mouse_click_on_window_focus boolean
---@field swap_backspace_and_delete boolean
---@field switch_to_last_active_tab_when_closing_tab boolean
---@field tab_and_split_indices_are_zero_based boolean
---@field tab_bar_at_bottom boolean
---@field tab_bar_style _.wezterm.TabBarStyle
---@field tab_max_width number
---@field term string
---@field text_background_opacity number
---@field text_blink_ease_in _.wezterm.EasingFunction
---@field text_blink_ease_out _.wezterm.EasingFunction
---@field text_blink_rapid_ease_in _.wezterm.EasingFunction
---@field text_blink_rapid_ease_out _.wezterm.EasingFunction
---@field text_blink_rate number
---@field text_blink_rate_rapid number
---@field tiling_desktop_environments string[]
---@field tls_clients _.wezterm.TlsDomainClient[]
---@field tls_servers _.wezterm.TlsDomainServer[]
---@field treat_east_asian_ambiguous_width_as_wide boolean
---@field treat_left_ctrlalt_as_altgr boolean
---@field ulimit_nofile number
---@field ulimit_nproc number
---@field underline_position number | string
---@field underline_thickness number | string
---@field unicode_version number
---@field unix_domains _.wezterm.MultiplexerDomain[]
---@field unzoom_on_switch_pane boolean
---@field use_cap_height_to_scale_fallback_fonts boolean
---@field use_dead_keys boolean
---@field use_fancy_tab_bar boolean
---@field use_ime boolean
---@field use_resize_increments boolean
---@field visual_bell _.wezterm.VisualBellConfig
---@field warn_about_missing_glyphs boolean
---@field webgpu_force_fallback_adapter boolean
---@field webgpu_power_preference 'LowPower' | 'HighPower'
---@field webgpu_preferred_adapter _.wezterm.GpuInfo
---@field win32_acrylic_accent_color string
---@field win32_system_backdrop 'Auto' | 'Disable' | 'Acrylic' | 'Mica' | 'Tabbed'
---@field window_background_image string
---@field window_background_image_hsb _.wezterm.HsbTransform
---@field window_background_gradient _.wezterm.Gradient[]
---@field window_background_opacity number
---@field window_close_confirmation 'NeverPrompt' | 'AlwaysPrompt'
---@field window_decorations string
---@field window_frame _.wezterm.WindowFrame
---@field window_padding _.wezterm.WindowPadding
---@field wsl_domains _.wezterm.WslDomain[]
---@field xim_im_name string
local ConfigBuilder = {}

---@param strict_mode boolean
function ConfigBuilder:set_strict_mode(strict_mode) end
