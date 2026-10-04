if status is-interactive
    if command -q zoxide
        zoxide init fish --cmd cd | source
    end
end
