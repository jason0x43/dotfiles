# Resize splits by moving a border instead of growing/shrinking the window.
#
# `kitten border_resize.py <left|right|up|down> [cells]` moves one of the
# active window's borders in the given direction. When the window has borders
# on both sides along that axis, the right (or bottom) one moves; otherwise the
# only border there moves. Only the splits layout is supported.

from collections.abc import Sequence

from kittens.tui.handler import result_handler
from kitty.boss import Boss

DEFAULT_CELLS = {True: 2, False: 1}


def find_divider(path, horizontal: bool):
    """Find the divider closest to the window on its right/bottom side, falling
    back to the closest one on its left/top side"""
    fallback = None
    for pair, in_one in reversed(path):
        if pair.is_redundant or pair.horizontal != horizontal:
            continue
        # A window in the first child of a pair touches the divider with its
        # right/bottom edge; a window in the second touches it with its
        # left/top edge
        if in_one:
            return pair
        if fallback is None:
            fallback = pair
    return fallback


@result_handler(no_ui=True)
def handle_result(args: Sequence[str], result: str, target_window_id: int, boss: Boss):
    window = boss.window_id_map.get(target_window_id)
    tab = window.tabref() if window else None
    if window is None or tab is None or tab.current_layout.name != "splits":
        return

    direction = args[1]
    horizontal = direction in ("left", "right")
    forward = direction in ("right", "down")
    cells = float(args[2]) if len(args) > 2 else DEFAULT_CELLS[horizontal]

    group = tab.windows.group_for_window(window)
    if group is None:
        return
    path = tab.current_layout.pairs_root.find_window_in_tree(group.id)
    if not path:
        return

    pair = find_divider(path, horizontal)
    if pair is not None:
        tab.drag_resize_window(id(pair), cells if forward else -cells, horizontal)


def main():
    pass
