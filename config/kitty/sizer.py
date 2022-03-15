# Handle navigating between various splits (vim, kitty, tmux)

from typing import Any, Sequence, cast
from collections import namedtuple

from kittens.tui.handler import result_handler
from kittens.tui.loop import debug
from kitty.typing import BossType, EdgeLiteral
from kitty.types import WindowGeometry
from kitty.window import Window
from  kitty.options.utils import resize_window


@result_handler(no_ui=True)
def handle_result(
    args: Sequence[str], data: Any, target_window_id: int, boss: BossType
):
    quality = args[1]

    tab = boss.active_tab
    if tab:
        tab.resize_window(quality, 1)


def main():
    pass
