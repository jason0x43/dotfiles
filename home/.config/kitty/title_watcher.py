# Keep each OS window's title in sync with its active tab's title. By default
# kitty uses the active window's title and ignores names set with
# set_tab_title.

from typing import Any

from kitty.boss import Boss
from kitty.fast_data_types import set_os_window_title
from kitty.window import Window


def on_tab_bar_dirty(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    """Called for tab switches, renames, and window title changes"""
    tm = data["tab_manager"]
    tab = tm.active_tab
    if tab is not None:
        set_os_window_title(tm.os_window_id, tab.effective_title)
