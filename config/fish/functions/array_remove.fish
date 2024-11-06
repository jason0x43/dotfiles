function array_remove -a var -a array
    if contains $var $$array
        set -e "$array"[(contains -i $var $$array)]
    end
end
