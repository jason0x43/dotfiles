#!/bin/bash

if [[ $1 == "base16" ]]; then
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n"  "0" "7" "base00 ( 0)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n" "18" "7" "base01 (18)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n" "19" "7" "base02 (19)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n"  "8" "7" "base03 ( 8)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n" "20" "0" "base04 (20)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n"  "7" "0" "base05 ( 7)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n" "21" "0" "base06 (21)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n" "15" "0" "base07 (15)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n"  "1" "0" "base08 ( 1)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n" "16" "0" "base09 (16)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n"  "3" "0" "base0A ( 3)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n"  "2" "0" "base0B ( 2)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n"  "6" "0" "base0C ( 6)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n"  "4" "0" "base0D ( 4)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n"  "5" "0" "base0E ( 5)"
    printf "\e[48;5;%sm\e[38;5;%sm%s\e[0m\n" "17" "0" "base0F (17)"
elif [[ $1 == "true" ]]; then
    # Based on: https://gist.github.com/XVilka/8346728
    awk -v term_cols="${width:-$(tput cols || echo 80)}" 'BEGIN{
        s="/\\";
        for (colnum = 0; colnum<term_cols; colnum++) {
            r = 255-(colnum*255/term_cols);
            g = (colnum*510/term_cols);
            b = (colnum*255/term_cols);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum%2+1,1);
        }
        printf "\n";
    }'
elif [[ $1 == "base" ]]; then
    for i in {0..21} ; do
        printf "\x1b[48;5;%sm%3d\e[0m " "$i" "$i"
        if (( (i + 1) % 8 == 0 )); then
            printf "\n";
        fi
    done
else
    for i in {0..255} ; do
        printf "\x1b[48;5;%sm%3d\e[0m " "$i" "$i"
        # if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
        if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
            printf "\n";
        fi
    done
fi
