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
bd=1;33\
:ca=0\
:cd=1;33\
:di=1;94\
:do=1;35\
:ex=1;32\
:fi=0;37\
:ln=0;35\
:mh=0\
:mi=1;31\
:no=0;37\
:or=1;31\
:ow=0\
:pi=1;33\
:rs=0;37\
:sg=0\
:so=1;35\
:st=0\
:su=0\
:tw=0"

# Archive and compressed files (red, bold)
set -l ls_archives "\
*.7z=1;36\
:*.apk=1;36\
:*.arj=1;36\
:*.bag=1;36\
:*.bin=1;36\
:*.bz=1;36\
:*.bz2=1;36\
:*.db=1;36\
:*.deb=1;36\
:*.dmg=1;36\
:*.img=1;36\
:*.iso=1;36\
:*.jar=1;36\
:*.msi=1;36\
:*.pkg=1;36\
:*.rar=1;36\
:*.rpm=1;36\
:*.tar=1;36\
:*.tbz=1;36\
:*.tbz2=1;36\
:*.tgz=1;36\
:*.toast=1;36\
:*.vcd=1;36\
:*.xbps=1;36\
:*.xz=1;36\
:*.z=1;36\
:*.zip=1;36\
:*.zst=1;36\
:*.gz=1;36"

# Source code files (white/light gray)
set -l ls_source "\
*.asm=0;38\
:*.awk=0;38\
:*.bash=0;38\
:*.bat=0;38\
:*.c=0;38\
:*.c++=0;38\
:*.cc=0;38\
:*.cpp=0;38\
:*.css=0;38\
:*.csx=0;38\
:*.cxx=0;38\
:*.d=0;38\
:*.dart=0;38\
:*.def=0;38\
:*.fish=0;38\
:*.go=0;38\
:*.gradle=0;38\
:*.groovy=0;38\
:*.h=0;38\
:*.h++=0;38\
:*.hh=0;38\
:*.hpp=0;38\
:*.htm=0;38\
:*.html=0;38\
:*.hxx=0;38\
:*.java=0;38\
:*.js=0;38\
:*.jsx=0;38\
:*.kt=0;38\
:*.lisp=0;38\
:*.lua=0;38\
:*.php=0;38\
:*.pl=0;38\
:*.ps1=0;38\
:*.psd1=0;38\
:*.psm1=0;38\
:*.py=0;38\
:*.r=0;38\
:*.scala=0;38\
:*.sh=0;38\
:*.sql=0;38\
:*.swift=0;38\
:*.tcl=0;38\
:*.ts=0;38\
:*.tsx=0;38\
:*.vim=0;38\
:*.zig=0;38\
:*.zsh=0;38\
:*.applescript=0;38\
:*.bash_profile=0;38\
:*.bashrc=0;38"

# Various special files
set -l ls_special "\
:*README=1;33\
:*README.md=1;33\
:*TODO=1;33"

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
set -gx LS_COLORS "$ls_base:$ls_archives:$ls_source:$ls_temp:$ls_special"

# Disable EZA's default highlighting in favor of this one
set -gx EZA_COLORS "reset"
