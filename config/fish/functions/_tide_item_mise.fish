function _tide_item_mise
    if ! command -q mise
      return
    end

    set -f plugins (mise current)
    for plugin in $plugins
        set -l parts (string split ' ' $plugin)
        set -l tool $parts[1]
        set -l ver $parts[2]
        set -l icon_var tide_"$tool"_icon
        _tide_print_item $tool (eval echo \$$icon_var)' ' $ver
    end
end
