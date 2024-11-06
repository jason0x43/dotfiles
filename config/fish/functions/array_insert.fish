function array_insert -a val -a index -a array
    set -l arr $$array
    set -U "$array" $arr[1..$index] $val $arr[(math $index + 1)..]
end
