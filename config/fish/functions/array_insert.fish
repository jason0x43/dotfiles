function array_insert -a val -a index -a array -d "Insert a value into an array at a given index"
    set -l arr $$array
    set -U "$array" $arr[1..$index] $val $arr[(math $index + 1)..]
end
