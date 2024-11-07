function array_remove -a var -a array -d "Remove the first occurance of a value from an array"
    if contains $var $$array
        set -e "$array"[(contains -i $var $$array)]
    end
end
