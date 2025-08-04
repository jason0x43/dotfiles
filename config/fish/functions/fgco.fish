function fgco
    git checkout "$(git branch --all | grep -v HEAD | sed 's/^[* ] //' | fzf)"
end

