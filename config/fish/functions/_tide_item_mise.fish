function _tide_item_mise
    if ! command -q mise
      return
    end

    set -f plugins (mise current)
    for plugin in $plugins
        set -l parts (string split ' ' $plugin)
        set -l tool $parts[1]
        set -l ver $parts[2]

        if string match -q "*@*" $ver
            set -l subparts (string split '@' $ver)
            set ver $subparts[2]
        end

        set -l icon_var tide_"$tool"_icon
        _tide_print_item $tool $$icon_var' ' $ver
    end
end
