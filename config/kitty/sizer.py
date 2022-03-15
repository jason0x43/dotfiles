# Handle resizing windows (panes)

from typing import Any, Dict, Optional, Sequence

from kittens.tui.handler import result_handler
from kittens.tui.loop import debug
from kitty.typing import BossType


def get_split_type(window_id: int, layout_pair: Dict[str, Any]) -> Optional[str]:
    if layout_pair['one'] == window_id or layout_pair['two'] == window_id:
        return 'horizontal' if layout_pair['horizontal'] else 'vertical'
    if isinstance(layout_pair['one'], dict):
        return get_split_type(window_id, layout_pair['one'])
    if isinstance(layout_pair['two'], dict):
        return get_split_type(window_id, layout_pair['two'])
    return None


@result_handler(no_ui=True)
def handle_result(
    args: Sequence[str], data: Any, target_window_id: int, boss: BossType
):
    quality = args[1]

    tab = boss.active_tab
    if tab:
        layout = tab.current_layout.layout_state()
        if quality == 'bigger' or quality == 'smaller':
            split_type = get_split_type( target_window_id, layout['pairs'])
            if split_type is None:
                return
            if split_type == 'horizontal':
                quality = 'wider' if quality == 'bigger' else 'narrower'
            else:
                quality = 'taller' if quality == 'bigger' else 'shorter'
        tab.resize_window(quality, 1)


def main():
    pass
