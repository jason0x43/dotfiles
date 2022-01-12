from typing import List
from kitty.boss import Boss


def main(args: List[str]) -> str:
    if len(args) < 3 or args[2] != "samehost":
        return input("Remote host: ")
    return ""


def handle_result(
    args: List[str], answer: str, target_window_id: int, boss: Boss
) -> None:
    target = answer

    if target == "" and len(args) > 2 and args[2] == "samehost":
        w = boss.window_id_map.get(target_window_id)
        if w is not None:
            for proc in reversed(w.child.foreground_processes):
                cmdline = proc["cmdline"]
                if cmdline is not None:
                    if cmdline[0] == "ssh" or cmdline[0].endswith("/ssh"):
                        target = cmdline[1]
                        break

    if target == "":
        return

    host = target.split("@")[1]
    location = args[1]

    if location == "tab":
        boss.launch("--type=tab", f"--title= {host}", "ssh", target)
    elif location == "vsplit":
        boss.launch(
            "--type=window", "--location=vsplit", f"--title= {host}", "ssh", target
        )
    elif location == "hsplit":
        boss.launch(
            "--type=window", "--location=hsplit", f"--title= {host}", "ssh", target
        )

