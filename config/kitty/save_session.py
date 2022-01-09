from typing import cast, Any, Dict, List, Sequence
from kittens.tui.handler import result_handler
from kitty.typing import BossType
from kitty.child import ProcessDesc
from kitty.boss import OSWindowDict
from kitty.tabs import TabDict
from kitty.window import Window
from os import getenv
from pathlib import Path
from datetime import datetime
import json


home = cast(str, getenv("HOME"))
data_dir = Path(home).joinpath(".local/share/kitty")
data_dir.mkdir(parents=True, exist_ok=True)
buf_dir = data_dir.joinpath("buffers")
buf_dir.mkdir(exist_ok=True)


def to_split_list(layout: Dict[str, Any]) -> List[str]:
    """Return an ordered list of splits from a layout dict"""
    splits = []
    pairs = layout["pairs"]
    while pairs:
        if pairs["one"] and pairs["two"]:
            if pairs["horizontal"]:
                splits.append("vsplit")
            else:
                splits.append("hsplit")

        if isinstance(pairs["two"], int):
            pairs = None
        else:
            pairs = pairs["two"]
    return splits


def is_single_window(tab: TabDict) -> bool:
    """Return true if the tab contains only one window"""
    return not tab["layout_state"]["pairs"]["two"]


def get_win_size(os_win: OSWindowDict) -> Dict[str, int]:
    """Get the overall window size in character cells"""
    for tab in os_win["tabs"]:
        if is_single_window(tab):
            return {
                "width": tab["windows"][0]["columns"],
                "height": tab["windows"][0]["lines"],
            }

    tab = os_win["tabs"][0]
    splits = to_split_list(tab["layout_state"])
    height = tab["windows"][0]["lines"]
    width = tab["windows"][0]["columns"]
    for index, win in enumerate(tab["windows"][1:]):
        # since splits happen in-between windows, there will be fewer splits
        # than windows
        split = splits[min(index, len(splits) - 1)]
        if split == "hsplit":
            height += win["lines"]
        else:
            width += win["columns"]

    return {"width": width, "height": height}


def env_to_str(env: Dict[str, str]) -> str:
    """Return a set of --env arguments for an env dict"""
    return " ".join([f"--env {key}={env[key]}" for key in env]).strip()


def cmdline_to_str(cmdline: str) -> str:
    """Return a single command string for command array"""
    cmd = " ".join([f"{e}" for e in cmdline]).strip()
    if cmd == "-zsh":
        return cast(str, getenv("SHELL"))
    return cmd


def fg_proc_to_str(procs: Sequence[ProcessDesc]) -> str:
    """Return a command string for a set of foreground processes"""
    # The last command is typically the interactive one
    proc = procs[-1]
    s = f"{cmdline_to_str(proc['cmdline'])}"
    if s.startswith("ssh ") or s.startswith("/usr/bin/ssh "):
        return s
    # For now, just return the shell command in most cases
    return cast(str, getenv("SHELL"))


def has_fg_process(win: Window) -> bool:
    """Return true if this window is running a child foreground process"""
    return len(win.child.foreground_processes) > 1


@result_handler(no_ui=True)
def handle_result(
    args: Sequence[str], data: Any, target_window_id: int, boss: BossType
):
    # save the session JSON in case it's useful
    with data_dir.joinpath("session.json").open(mode="w") as session_file:
        data = list(boss.list_os_windows())
        json.dump(data, session_file, indent=2)

    # create a session file by walking through the OS windows list
    with data_dir.joinpath("session.ini").open(mode="w") as session_file:
        first = True

        for os_win in boss.list_os_windows():
            if first:
                # don't call new_os_window for the first window since it
                # implicitly gets a new window
                first = False
            else:
                print("new_os_window", file=session_file)

            # set the window size; this command does nothing for the implicit
            # first window, but it's used by the kitty_restore script to set
            # the size of the initial window
            size = get_win_size(os_win)
            print(
                f"os_window_size {size['width']}c {size['height']}c", file=session_file
            )

            for tab in os_win["tabs"]:
                print(f"new_tab {tab['title']}", file=session_file)
                print(f"layout {tab['layout']}", file=session_file)

                split_list = to_split_list(tab["layout_state"])
                split = None

                for w in tab["windows"]:
                    print(f"title {w['title']}", file=session_file)

                    launch_cmd = [f"launch --cwd {w['cwd']}"]
                    if w["env"]:
                        launch_cmd.append(env_to_str(w["env"]))
                    if split:
                        launch_cmd.append(f"--location {split}")
                    buf_file = buf_dir.joinpath(f"{w['id']}.txt")
                    launch_cmd.append(f"kitty_restore_window {buf_file}")
                    launch_cmd.append(fg_proc_to_str(w["foreground_processes"]))

                    print(" ".join(launch_cmd), file=session_file)

                    if w["is_focused"]:
                        print("focus", file=session_file)

                    if len(split_list) > 0:
                        split = split_list.pop(0)
                    else:
                        split = None

            print("", file=session_file)

    # clear any existing saved buffers
    for buf in buf_dir.glob("*.txt"):
        buf.unlink()

    # save the scrollback buffers for all windows
    for win in boss.all_windows:
        with buf_dir.joinpath(f"{win.id}.txt").open(mode="w") as buf_file:
            # If the window is running a foreground process (other than its
            # base shell), take the alternate text since we don't want the
            # contents of a full-screen app
            text = win.as_text(
                as_ansi=True, add_history=True, alternate_screen=has_fg_process(win)
            )
            buf_file.write(text.strip())

    return f"Session saved at {datetime.now()}"


def main(args):
    pass
