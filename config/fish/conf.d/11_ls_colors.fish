# Filetypes
#
# bd: block device
# ca: file with capability
# cd: character device
# di: directory
# do: door - file for IPC (solaris only)
# ex: executable
# fi: normal file
# ln: symbolic link; can set to 'target' to color as the pointed to file
# mh: multi-hardlink
# mi: missing file (broken symlink)
# no: normal - non-filename text (unset by default)
# or: orphaned (broken symlink)
# ow: other-writeable directory
# pi: named pipe (fifo file)
# sg: setgid file
# so: socket file
# st: directory with sticky bit set (+t) that isn't other-writable
# su: setuid file
# tw: directory that is sticky with other-writable set (+t,o+w)
#
# Text styles
#
# 0: default
# 1: bold
# 4: underline
# 5: flashing
#
# Foreground color codes
#
# 30-37: black - white
# 90-97: br_black - br_white
#
# Background color codes
#
# 40-47: black-white

# Standard LS_COLORS file types
set -l ls_base "\
bd=1;33;40\
:ca=0\
:cd=1;33;40\
:di=1;94\
:do=1;35;40\
:ex=1;32\
:fi=0;37\
:ln=1;36\
:mh=0\
:mi=1;31;40\
:no=0;37\
:or=1;31;40\
:ow=0\
:pi=1;33;40\
:rs=0;37\
:sg=0\
:so=1;35;40\
:st=0\
:su=0\
:tw=0"

# Archive and compressed files (red, bold)
set -l ls_archives "\
*.7z=1;31\
:*.apk=1;31\
:*.arj=1;31\
:*.bag=1;31\
:*.bin=1;31\
:*.bz=1;31\
:*.bz2=1;31\
:*.db=1;31\
:*.deb=1;31\
:*.dmg=1;31\
:*.img=1;31\
:*.iso=1;31\
:*.jar=1;31\
:*.msi=1;31\
:*.pkg=1;31\
:*.rar=1;31\
:*.rpm=1;31\
:*.tar=1;31\
:*.tbz=1;31\
:*.tbz2=1;31\
:*.tgz=1;31\
:*.toast=1;31\
:*.vcd=1;31\
:*.xbps=1;31\
:*.xz=1;31\
:*.z=1;31\
:*.zip=1;31\
:*.zst=1;31\
:*.gz=1;31"

# Source code files (white/light gray)
set -l ls_source "\
*.1=0;37\
:*.a=0;37\
:*.adb=0;37\
:*.ads=0;37\
:*.as=0;37\
:*.asa=0;37\
:*.asm=0;37\
:*.awk=0;37\
:*.bash=0;37\
:*.bat=0;37\
:*.bib=0;37\
:*.bsh=0;37\
:*.bst=0;37\
:*.c=0;37\
:*.c++=0;37\
:*.cabal=0;37\
:*.cc=0;37\
:*.cfg=0;37\
:*.cgi=0;37\
:*.clj=0;37\
:*.cmake=0;37\
:*.com=0;37\
:*.conf=0;37\
:*.config=0;37\
:*.cp=0;37\
:*.cpp=0;37\
:*.cr=0;37\
:*.cs=0;37\
:*.css=0;37\
:*.csv=0;37\
:*.csx=0;37\
:*.cxx=0;37\
:*.d=0;37\
:*.dart=0;37\
:*.def=0;37\
:*.desktop=0;37\
:*.di=0;37\
:*.diff=0;37\
:*.dll=0;37\
:*.dylib=0;37\
:*.el=0;37\
:*.elc=0;37\
:*.elm=0;37\
:*.epp=0;37\
:*.erl=0;37\
:*.ex=0;37\
:*.exe=0;37\
:*.exs=0;37\
:*.fish=0;37\
:*.fs=0;37\
:*.fsi=0;37\
:*.fsx=0;37\
:*.gcode=0;37\
:*.gemspec=0;37\
:*.go=0;37\
:*.gradle=0;37\
:*.groovy=0;37\
:*.gv=0;37\
:*.gvy=0;37\
:*.h=0;37\
:*.h++=0;37\
:*.ha=0;37\
:*.hack=0;37\
:*.hh=0;37\
:*.hpp=0;37\
:*.hgrc=0;37\
:*.hs=0;37\
:*.htc=0;37\
:*.htm=0;37\
:*.html=0;37\
:*.hxx=0;37\
:*.ignore=0;37\
:*.inc=0;37\
:*.info=0;37\
:*.ini=0;37\
:*.inl=0;37\
:*.ino=0;37\
:*.ipp=0;37\
:*.ipynb=0;37\
:*.java=0;37\
:*.jl=0;37\
:*.js=0;37\
:*.json=0;37\
:*.jsx=0;37\
:*.ko=0;37\
:*.kt=0;37\
:*.kts=0;37\
:*.less=0;37\
:*.lisp=0;37\
:*.ll=0;37\
:*.ltx=0;37\
:*.lua=0;37\
:*.m=0;37\
:*.mailmap=0;37\
:*.make=0;37\
:*.markdown=0;37\
:*.matlab=0;37\
:*.md=0;37\
:*.mdown=0;37\
:*.mir=0;37\
:*.mk=0;37\
:*.ml=0;37\
:*.mli=0;37\
:*.mn=0;37\
:*.mojo=0;37\
:*.nb=0;37\
:*.nim=0;37\
:*.nimble=0;37\
:*.nims=0;37\
:*.nix=0;37\
:*.nu=0;37\
:*.org=0;37\
:*.p=0;37\
:*.pas=0;37\
:*.patch=0;37\
:*.php=0;37\
:*.pl=0;37\
:*.pm=0;37\
:*.pod=0;37\
:*.pp=0;37\
:*.pro=0;37\
:*.prql=0;37\
:*.ps1=0;37\
:*.psd1=0;37\
:*.psm1=0;37\
:*.purs=0;37\
:*.py=0;37\
:*.r=0;37\
:*.raku=0;37\
:*.rb=0;37\
:*.rs=0;37\
:*.rst=0;37\
:*.sass=0;37\
:*.sbt=0;37\
:*.scad=0;37\
:*.scala=0;37\
:*.scss=0;37\
:*.sh=0;37\
:*.shtml=0;37\
:*.so=0;37\
:*.sql=0;37\
:*.swift=0;37\
:*.t=0;37\
:*.tcl=0;37\
:*.td=0;37\
:*.tex=0;37\
:*.tml=0;37\
:*.toml=0;37\
:*.ts=0;37\
:*.tsx=0;37\
:*.txt=0;37\
:*.typ=0;37\
:*.ui=0;37\
:*.v=0;37\
:*.vb=0;37\
:*.vim=0;37\
:*.vsh=0;37\
:*.xhtml=0;37\
:*.xml=0;37\
:*.xmp=0;37\
:*.yaml=0;37\
:*.yml=0;37\
:*.zig=0;37\
:*.zsh=0;37\
:*CHANGELOG=0;37\
:*CODEOWNERS=0;37\
:*CONTRIBUTING=0;37\
:*CONTRIBUTORS=0;37\
:*COPYING=0;37\
:*COPYRIGHT=0;37\
:*Doxyfile=0;37\
:*Dockerfile=0;37\
:*FAQ=0;37\
:*INSTALL=0;37\
:*LEGACY=0;37\
:*LICENCE=0;37\
:*LICENSE=0;37\
:*Makefile=0;37\
:*NOTICE=0;37\
:*README=0;37\
:*TODO=1;37\
:*VERSION=0;37\
:*configure=0;37\
:*go.mod=0;37\
:*hgrc=0;37\
:*passwd=0;37\
:*setup.py=0;37\
:*shadow=0;37\
:*v.mod=0;37\
:*.applescript=0;37\
:*.bash_profile=0;37\
:*.bashrc=0;37\
:*.cirrus.yml=0;37\
:*.clang-format=0;37\
:*.cmake.in=0;37\
:*.editorconfig=0;37\
:*.fdignore=0;37\
:*.flake8=0;37\
:*.gitattributes=0;37\
:*.gitconfig=0;37\
:*.gitignore=0;37\
:*.gitmodules=0;37\
:*.gitlab-ci.yml=0;37\
:*.kdevelop=0;37\
:*.rgignore=0;37\
:*.tfignore=0;37\
:*.travis.yml=0;37\
:*.webmanifest=0;37\
:*CHANGELOG.md=0;37\
:*CHANGELOG.txt=0;37\
:*CMakeLists.txt=0;37\
:*CODE_OF_CONDUCT=0;37\
:*CONTRIBUTING.md=0;37\
:*CONTRIBUTING.txt=0;37\
:*CONTRIBUTORS.md=0;37\
:*CONTRIBUTORS.txt=0;37\
:*INSTALL.md=0;37\
:*INSTALL.txt=0;37\
:*LICENSE-APACHE=0;37\
:*LICENSE-MIT=0;37\
:*MANIFEST.in=0;37\
:*Makefile.am=0;37\
:*README.md=0;37\
:*README.txt=0;37\
:*SConscript=0;37\
:*SConstruct=0;37\
:*TODO.md=1;37\
:*TODO.txt=1;37\
:*appveyor.yml=0;37\
:*azure-pipelines.yml=0;37\
:*configure.ac=0;37\
:*pyproject.toml=0;37\
:*requirements.txt=0;37\
:*CODE_OF_CONDUCT.md=0;37\
:*CODE_OF_CONDUCT.txt=0;37"

# Temporary and build artifacts (bright black/dark gray)
set -l ls_temp "\
*~=0;90\
:*.aux=0;90\
:*.bak=0;90\
:*.bc=0;90\
:*.bbl=0;90\
:*.bcf=0;90\
:*.blg=0;90\
:*.cache=0;90\
:*.class=0;90\
:*.ctags=0;90\
:*.dyn_hi=0;90\
:*.dyn_o=0;90\
:*.fdb_latexmk=0;90\
:*.fls=0;90\
:*.git=0;90\
:*.hi=0;90\
:*.idx=0;90\
:*.ilg=0;90\
:*.ind=0;90\
:*.la=0;90\
:*.lo=0;90\
:*.lock=0;90\
:*.log=0;90\
:*.o=0;90\
:*.orig=0;90\
:*.out=0;90\
:*.pid=0;90\
:*.pyc=0;90\
:*.pyd=0;90\
:*.pyo=0;90\
:*.rlib=0;90\
:*.rmeta=0;90\
:*.sty=0;90\
:*.swp=0;90\
:*.tmp=0;90\
:*.toc=0;90\
:*Icon\r=0;90\
:*go.sum=0;90\
:*stderr=0;90\
:*stdin=0;90\
:*stdout=0;90\
:*.DS_Store=0;90\
:*.localized=0;90\
:*.scons_opt=0;90\
:*.sconsign.dblite=0;90\
:*.synctex.gz=0;90\
:*.timestamp=0;90\
:*CMakeCache.txt=0;90\
:*Makefile.in=0;90\
:*bun.lockb=0;90\
:*package-lock.json=0;90\
:*.CFUserTextEncoding=0;90"

# Combine all groups into LS_COLORS
set -gx LS_COLORS "$ls_base:$ls_archives:$ls_source:$ls_temp"
