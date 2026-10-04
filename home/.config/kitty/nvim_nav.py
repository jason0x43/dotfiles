# Handle navigating between various splits (vim, kitty, tmux)

import re
from typing import Sequence
from kittens.tui.handler import result_handler
from kitty.key_encoding import KeyEvent, parse_shortcut
from kitty.boss import Boss
from kitty.window import Window


def is_vim_window(window: Window):
    """Indicate whether nvim is the frontmost process in a given window"""
    fp = window.child.foreground_processes
    for p in fp:
        cmdline = p["cmdline"]
        if cmdline and len(cmdline) and re.search(r"\bn?vim\b$", cmdline[0]):
            return True
    return False


def encode_key(window: Window, key_mapping: str):
    """Encode a key mapping to send to a process"""
    mods, key = parse_shortcut(key_mapping)
    return window.encoded_key(
        KeyEvent(
            mods=mods,
            key=key,
            shift=bool(mods & 1),
            alt=bool(mods & 2),
            ctrl=bool(mods & 4),
            super=bool(mods & 8),
            hyper=bool(mods & 16),
            meta=bool(mods & 32),
        ).as_window_system_event()
    )


def normalize_dir(dir: str):
    """Normalize a direction name"""
    if dir == "up" or dir == "top":
        return "top"
    if dir == "down" or dir == "bottom":
        return "bottom"
    if dir == "left":
        return "left"
    return "right"


def get_mapping(dir: str):
    """Get the key mapping for a direction"""
    if dir == "up" or dir == "top":
        return "ctrl+k"
    if dir == "down" or dir == "bottom":
        return "ctrl+j"
    if dir == "left":
        return "ctrl+h"
    return "ctrl+l"


@result_handler(no_ui=True)
def handle_result(args: Sequence[str], result: str, target_window_id: int, boss: Boss):
    window = boss.window_id_map.get(target_window_id)

    if window is None:
        return

    if is_vim_window(window) and args[1] != "nvim":
        window.write_to_child(encode_key(window, get_mapping(args[2])))
    elif boss.active_tab:
        boss.active_tab.neighboring_window(normalize_dir(args[2]))


def main():
    pass
