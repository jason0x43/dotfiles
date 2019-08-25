#!/usr/bin/env python3

import asyncio
import iterm2
from os import getenv


async def intercept_term_theme():
    # source the current base16 theme as if it weren't running in tmux; this
    # will be fed to other iterm windows
    proc = await asyncio.create_subprocess_shell(
        "source ~/.base16_theme", stdout=asyncio.subprocess.PIPE, env={"TMUX": ""}
    )
    return (await proc.communicate())[0]


async def get_iterm_sessions():
    connection = await iterm2.Connection.async_create()
    app = await iterm2.async_get_app(connection)
    current_tab = app.current_terminal_window.current_tab

    sessions = []
    for window in app.terminal_windows:
        for tab in [t for t in window.tabs if t != current_tab]:
            for session in tab.sessions:
                sessions.append(session)

    return sessions


async def update_iterm_sessions():
    code, sessions = await asyncio.gather(intercept_term_theme(), get_iterm_sessions())
    await asyncio.gather(*[s.async_inject(code) for s in sessions])


async def update_neovim_theme():
    proc = await asyncio.create_subprocess_shell(
        "nvr --serverlist", stdout=asyncio.subprocess.PIPE
    )
    stdout = (await proc.communicate())[0].decode("utf-8")
    sockets = [s for s in stdout.split("\n") if len(s) > 0]

    await asyncio.gather(
        *[
            asyncio.create_subprocess_shell(
                '''nvr --servername %s -c ":UpdateColors"''' % socket
            )
            for socket in sockets
        ]
    )


async def main():
    tasks = [update_neovim_theme()]

    if getenv('TERM_PROGRAM') == 'iTerm.app':
        tasks.append(update_iterm_sessions())

    await asyncio.gather(*tasks)


asyncio.get_event_loop().run_until_complete(main())
