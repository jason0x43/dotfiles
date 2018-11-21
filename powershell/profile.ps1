function ga { git add $args }
function gb { git branch $args }
function gba { git branch -a $args }

if (test-path alias:gc) { remove-item -force alias:gc }
function gc { git commit $args }

if (test-path alias:gl) { remove-item -force alias:gl }
function gl { git log --graph --abbrev-commit --date-order --format=format:'%Cblue%h%Creset%C(bold red)%d%Creset %s <%an> %Cgreen(%ar)%Creset' --all $args }
function glb { git log --graph --abbrev-commit --date-order --format=format:'%Cblue%h%Creset%C(bold red)%d%Creset %s <%an> %Cgreen(%ar)%Creset' $args }
function gs { git status --short $args }