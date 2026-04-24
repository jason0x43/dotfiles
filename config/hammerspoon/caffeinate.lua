---@return hs.image
local function loadImage(path)
	local img = hs.image.imageFromPath(path)
  if not img then
    error("Failed to load image from path: " .. path)
  end
	return img
end

---@return hs.menubar
local function createMenu()
  local menu = hs.menubar.new()
  if not menu then
    error("Failed to create menubar item")
  end
  return menu
end

local empty_img =
	loadImage(os.getenv("HOME") .. "/.config/hammerspoon/pot-empty.svg")
local filled_img =
	loadImage(os.getenv("HOME") .. "/.config/hammerspoon/pot-filled.svg")

-- Add a caffeine menubar icon
Caffeine = {
	running = false,
	icon_empty = empty_img:setSize({ h = 18, w = 18 }),
	icon_filled = filled_img:setSize({ h = 18, w = 18 }),
}

Caffeine.menu = createMenu()
Caffeine.menu:setIcon(Caffeine.icon_empty)

-- Poll for caffeinate status; not the most efficient, but flexible
Caffeine.watcher = hs.timer.doEvery(2, function()
	local running = hs.execute("pgrep caffeinate") ~= ""
	if running and not Caffeine.running then
		Caffeine.running = true
		Caffeine.menu:setIcon(Caffeine.icon_filled)
	elseif not running and Caffeine.running then
		Caffeine.running = false
		Caffeine.menu:setIcon(Caffeine.icon_empty)
	end
end)
