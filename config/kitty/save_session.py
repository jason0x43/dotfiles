from typing import cast, Any, Dict, List, Sequence
from kittens.tui.handler import result_handler
from kitty.typing import BossType
from kitty.child import ProcessDesc
from kitty.boss import OSWindowDict
from kitty.tabs import TabDict
from os import getenv
from pathlib import Path
import json


home = cast(str, getenv("HOME"))
data_dir = Path(home).joinpath(".local/share/kitty")
data_dir.mkdir(parents=True, exist_ok=True)


def to_split_list(layout: Dict[str, Any]) -> List[str]:
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
    return not tab["layout_state"]["pairs"]["two"]


def get_win_size(os_win: OSWindowDict) -> Dict[str, int]:
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
        split = splits[index]
        if split == "hsplit":
            height += win["lines"]
        else:
            width += win["columns"]

    return {"width": width, "height": height}


def env_to_str(env: Dict[str, str]) -> str:
    return " ".join([f"--env {key}={env[key]}" for key in env]).strip()


def cmdline_to_str(cmdline: str) -> str:
    cmd = " ".join([f"{e}" for e in cmdline]).strip()
    if cmd == "-zsh":
        return cast(str, getenv("SHELL"))
    return cmd


def fg_proc_to_str(procs: Sequence[ProcessDesc]) -> str:
    """Return a command string for a set of foreground processes"""
    # The last command is typically the interactive one
    proc = procs[-1]
    s = f"{cmdline_to_str(proc['cmdline'])}"
    if s.startswith("ssh "):
        return s
    # For now, just return the shell command in most cases
    return cast(str, getenv("SHELL"))


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
                first = False
            else:
                print("new_os_window", file=session_file)

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
                    launch_cmd.append(fg_proc_to_str(w["foreground_processes"]))

                    print(" ".join(launch_cmd), file=session_file)

                    if w["is_focused"]:
                        print("focus", file=session_file)

                    if len(split_list) > 0:
                        split = split_list.pop(0)
                    else:
                        split = None

            print("", file=session_file)


def main(args):
    pass
