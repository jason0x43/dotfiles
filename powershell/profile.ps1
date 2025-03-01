$ca_path = $env:USERPROFILE + '\.config\ssl\ca.pem'
if (test-path $ca_path) {
    $env:NODE_EXTRA_CA_CERTS = $ca_path
}

if (test-path alias:gc) { remove-item -force alias:gc }
if (test-path alias:gl) { remove-item -force alias:gl }
if (test-path alias:gp) { remove-item -force alias:gp }
if (test-path alias:cd) { remove-item -force alias:cd }

set-alias -name vi -value nvim
set-alias -name cd -value z
set-alias -name b -value Pop-Location
set-alias -name back -value Pop-Location
set-alias -name grep -value findstr

function ga { git add $args }
function gb { git branch $args }
function gba { git branch -a $args }
function gc { git commit $args }
function gca { git commit -a $args }
function gco { git checkout $args }
function gd { git diff $args }
function gf { git fetch $args }
function gfpr {
    $id = $args[0]
    git fetch -fu origin refs/pull/$id/head:pr/$id
    git checkout pr/$id
}
function gid { git rev-parse HEAD }
function gl { git log --graph --abbrev-commit --date-order --format=format:'%Cblue%h%Creset%C(bold red)%d%Creset %s <%an> %Cgreen(%ar)%Creset' --all $args }
function glb { git log --graph --abbrev-commit --date-order --format=format:'%Cblue%h%Creset%C(bold red)%d%Creset %s <%an> %Cgreen(%ar)%Creset' $args }
function gp { git pull $args }
function gri { git rebase -i  $args }
function grv { git remote -v }
function gs { git status --short $args }
function ln {
    $type = $args[0]
    $source = $args[1]
    $dest = $args[2]
    if ($type -ne "-s") {
        echo "Unknown link type"
        return -1
    }
    Get-ChildItem $source | ForEach-Object {
        $abspath = $_.FullName
        $filename = $_.Basename
        New-Item -ItemType SymbolicLink -Path "$dest/$filename" -Target $abspath
    }
}
function rgl { rg -l $args }
function ts { tig status $args }
function which { get-command $args }
function .. { cd .. }

function serve {
    param (
        [parameter(position=0)][string]$dir = ".",
        [string]$addr = "localhost",
        [int]$port = 8080
    )
    python3 -m http.server --directory $dir --bind $addr $port
}


if (Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\Microsoft.VisualStudio.DevShell.dll" -PathType Leaf) {
    Import-Module "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
    Enter-VsDevShell 53dd91bd -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"
}

Import-Module posh-git
Invoke-Expression (& { (zoxide init powershell | Out-String) -replace "Set-Location", "Push-Location" })
