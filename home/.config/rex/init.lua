-- Rex config, migrated from kitty (~/.config/kitty/kitty.d/mappings.conf).

-- ctrl+a is a prefix; ctrl+a twice still sends ctrl+a to the program.
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })

-- Tabs
rex.bind("shift+left", "client.tab.previous")                          -- mappings.conf:9
rex.bind("shift+right", "client.tab.next")                             -- mappings.conf:10
rex.bind("shift+cmd+left", "client.tab.move", { direction = "backward" }) -- mappings.conf:12
rex.bind("shift+cmd+right", "client.tab.move", { direction = "forward" }) -- mappings.conf:13

-- Pane resizing
rex.bind("alt+w", "pane.resize", { direction = "right" })              -- mappings.conf:15 wider
rex.bind("alt+t", "pane.resize", { direction = "down" })               -- mappings.conf:16 taller
rex.bind("alt+s", "pane.resize", { direction = "up" })                 -- mappings.conf:17 shorter
rex.bind("alt+n", "pane.resize", { direction = "left" })               -- mappings.conf:18 narrower

-- Splits
rex.bind("ctrl+a>shift+\\", "pane.split", { direction = "right" })     -- mappings.conf:20
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })             -- mappings.conf:21

-- Copy mode (vim-style scrollback selection)
rex.bind("ctrl+a>c", "pane.copy_mode.enter")

-- Config
rex.bind("ctrl+a>r", "client.config.reload")                           -- mappings.conf:41

-- shift+enter sends a newline (\n is ctrl+j)
rex.bind("shift+enter", "pane.send_key", { key = "ctrl+j" })           -- mappings.conf:50

-- Border resize mode (mappings.conf:30-39). kitty's border_resize.py kitten moves
-- the active split's border in a direction, which is what pane.resize does.
-- ctrl+a then h/j/k/l resizes once and enters the mode; h/j/k/l keep resizing;
-- escape leaves. Exclusive, so stray keys can't be typed into the shell by accident.
rex.action{
  name  = "resize_then_border_mode",
  title = "Resize Pane and Enter Border Resize Mode",
  args  = { direction = "string" },
  run   = function(ctx, args)
    rex.client.queue("pane.resize", { direction = args.direction })
    rex.client.queue("client.mode.enter", { name = "border_resize" })
  end,
}
rex.mode("border_resize", { exclusive = true })
rex.bind("border_resize/h", "pane.resize", { direction = "left" })     -- mappings.conf:31
rex.bind("border_resize/j", "pane.resize", { direction = "down" })     -- mappings.conf:32
rex.bind("border_resize/k", "pane.resize", { direction = "up" })       -- mappings.conf:33
rex.bind("border_resize/l", "pane.resize", { direction = "right" })    -- mappings.conf:34
rex.bind("border_resize/escape", "client.mode.exit")                   -- mappings.conf:35
rex.bind("border_resize/enter", "client.mode.exit")
rex.bind("ctrl+a>h", "resize_then_border_mode", { direction = "left" })  -- mappings.conf:36
rex.bind("ctrl+a>j", "resize_then_border_mode", { direction = "down" })  -- mappings.conf:37
rex.bind("ctrl+a>k", "resize_then_border_mode", { direction = "up" })    -- mappings.conf:38
rex.bind("ctrl+a>l", "resize_then_border_mode", { direction = "right" }) -- mappings.conf:39

-- Pane switching. When nvim is in the foreground the key goes to nvim, whose
-- ctrl+hjkl maps move between its own windows and call `rex focus` at the edge
-- (home/.config/nvim/lua/user/terminal.lua).
local function is_nvim(ctx)
  local ok, info = pcall(rex.block.call, "com.superlogical.terminal", "process", {})
  local fg = ok and info and info.foreground
  return fg ~= nil and (fg.name == "nvim" or fg.name == "vim")
end

local function nav(key, direction)
  rex.bind(key, function(ctx, ev)
    if is_nvim(ctx) then
      return false -- falls through to the terminal
    end
    -- rex.client.queue only works inside actions, so call the server directly.
    local _, err = rex.session.focus_direction{ direction = direction }
    if err ~= nil then
      rex.log("focus_direction failed: " .. tostring(err))
    end
    return true
  end)
end

nav("ctrl+h", "left")
nav("ctrl+j", "down")
nav("ctrl+k", "up")
nav("ctrl+l", "right")
