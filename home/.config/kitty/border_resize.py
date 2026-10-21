# Resize splits by moving a border instead of growing/shrinking the window.
#
# `kitten border_resize.py <left|right|up|down> [cells]` moves the active
# window's nearest border in the given direction toward that side. If the
# window has no border on that side (it's against the tab edge), the border on
# the opposite side moves instead. Only the splits layout is supported.

from collections.abc import Sequence

from kittens.tui.handler import result_handler
from kitty.boss import Boss

DEFAULT_CELLS = {True: 2, False: 1}


def find_divider(path, horizontal: bool, trailing: bool):
    """Find the divider closest to the window on the requested side, falling
    back to the closest one on the opposite side"""
    fallback = None
    for pair, in_one in reversed(path):
        if pair.is_redundant or pair.horizontal != horizontal:
            continue
        # A window in the first child of a pair touches the divider with its
        # right/bottom edge; a window in the second touches it with its
        # left/top edge
        if in_one == trailing:
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
    trailing = direction in ("right", "down")
    cells = float(args[2]) if len(args) > 2 else DEFAULT_CELLS[horizontal]

    group = tab.windows.group_for_window(window)
    if group is None:
        return
    path = tab.current_layout.pairs_root.find_window_in_tree(group.id)
    if not path:
        return

    pair = find_divider(path, horizontal, trailing)
    if pair is not None:
        tab.drag_resize_window(id(pair), cells if trailing else -cells, horizontal)


def main():
    pass
