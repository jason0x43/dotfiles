function set_iterm_palette
	set -U PALETTE_BASE00  '657B83'
	set -U PALETTE_BASE01  '586E75'
	set -U PALETTE_BASE02  '073642'
	set -U PALETTE_BASE03  '002B36'
	set -U PALETTE_BASE0   '839496'
	set -U PALETTE_BASE1   '93A1A1'
	set -U PALETTE_BASE2   'EEE8D5'
	set -U PALETTE_BASE3   'FDF6E3'
	set -U PALETTE_BLUE    '268BD2'
	set -U PALETTE_CYAN    '2AA198'
	set -U PALETTE_GREEN   '859900'
	set -U PALETTE_MAGENTA 'D33682'
	set -U PALETTE_ORANGE  'CB4B16'
	set -U PALETTE_RED     'DC322F'
	set -U PALETTE_VIOLET  '6C71C4'
	set -U PALETTE_YELLOW  'B58900'

	set_iterm_color '0' $PALETTE_BASE02  # black
	set_iterm_color '1' $PALETTE_RED     # red
	set_iterm_color '2' $PALETTE_GREEN   # green
	set_iterm_color '3' $PALETTE_YELLOW  # yellow
	set_iterm_color '4' $PALETTE_BLUE    # blue
	set_iterm_color '5' $PALETTE_MAGENTA # magenta
	set_iterm_color '6' $PALETTE_CYAN    # cyan
	set_iterm_color '7' $PALETTE_BASE2   # white
	set_iterm_color '8' $PALETTE_BASE03  # bright black
	set_iterm_color '9' $PALETTE_ORANGE  # bright red
	set_iterm_color 'A' $PALETTE_BASE01  # bright green
	set_iterm_color 'B' $PALETTE_BASE00  # bright yellow
	set_iterm_color 'C' $PALETTE_BASE0   # bright blue
	set_iterm_color 'D' $PALETTE_VIOLET  # bright magenta
	set_iterm_color 'E' $PALETTE_BASE1   # bright cyan
	set_iterm_color 'F' $PALETTE_BASE3   # bright white
end
