from neovim import attach
from os import listdir, environ
from os.path import join as pjoin

if __name__ == '__main__':
    tmpdir = environ['TMPDIR']
    sessions = [d for d in listdir(tmpdir) if d.startswith('nvim')]
    for session in sessions:
        try:
            nvim = attach('socket', path=pjoin(tmpdir, session, '0'))
            nvim.command('RefreshColors')
        except Exception as e:
            print e
