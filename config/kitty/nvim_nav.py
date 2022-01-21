# Handle navigating between various splits (vim, kitty, tmux)

import re
from typing import Any, Sequence, cast

from kittens.tui.handler import result_handler
from kitty.fast_data_types import encode_key_for_tty
from kitty.key_encoding import KeyEvent, parse_shortcut
from kitty.typing import BossType, EdgeLiteral
from kitty.window import Window


def window_has_pager(window: Window):
    fp = window.child.foreground_processes
    for p in fp:
        if (
            len(p["cmdline"]) > 1
            and re.search("\\bzsh$", p["cmdline"][0])
            and re.search("\\bnvim_pager$", p["cmdline"][1])
        ):
            return True
    return False


def window_has_navigable_proc(window: Window):
    fp = window.child.foreground_processes
    for p in fp:
        if re.search("\\b(n?vim|tmux)$", p["cmdline"][0]):
            return True
    return False


def encode_key_mapping(key_mapping: str):
    mods, key = parse_shortcut(key_mapping)
    event = KeyEvent(
        mods=mods,
        key=key,
        shift=bool(mods & 1),
        alt=bool(mods & 2),
        ctrl=bool(mods & 4),
        super=bool(mods & 8),
        hyper=bool(mods & 16),
        meta=bool(mods & 32),
    ).as_window_system_event()

    return encode_key_for_tty(
        event.key, event.shifted_key, event.alternate_key, event.mods, event.action
    )


@result_handler(no_ui=True)
def handle_result(
    args: Sequence[str], data: Any, target_window_id: int, boss: BossType
):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    source = args[1]
    direction = cast(EdgeLiteral, args[2])

    if source == "kitty":
        if window_has_navigable_proc(window) and not window_has_pager(window):
            key_mapping = args[3]
            encoded = encode_key_mapping(key_mapping)
            window.write_to_child(encoded)
            return

    if boss.active_tab:
        boss.active_tab.neighboring_window(direction)


def main():
    pass

