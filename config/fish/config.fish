if status is-interactive
    #abbr --add vi nvim
    #abbr --add gs git status
    #abbr --add gco git checkout
    #abbr --add ls eza -F

    fish_vi_key_bindings

    bind -M insert \ce forward-char

    zoxide init fish --cmd cd | source
end
