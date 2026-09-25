# Bubblegum palette
BG_PINK='\[\033[38;5;212m\]'
BG_HOTPINK='\[\033[38;5;205m\]'
BG_CYAN='\[\033[38;5;51m\]'
BG_MINT='\[\033[38;5;121m\]'
BG_PURPLE='\[\033[38;5;141m\]'
BG_YELLOW='\[\033[38;5;227m\]'
BG_RED='\[\033[38;5;203m\]'
BG_DIM='\[\033[38;5;245m\]'
RESET='\[\033[0m\]'

# Two-line prompt
PS1="${BG_PINK}╭─${BG_CYAN}Termux${BG_PINK}─[${BG_HOTPINK}\u${BG_DIM}@${BG_PURPLE}\h${BG_PINK}]─[${BG_YELLOW}\w${BG_PINK}]\n${BG_PINK}╰─${BG_MINT}❯${RESET} "

# exa/ls colors — plain ANSI (no \[ \])
export EZA_COLORS="di=38;5;212:ln=38;5;51:ex=38;5;121:git=38;5;227:ur=38;5;203:uw=38;5;227:ux=38;5;121:ue=38;5;203:gr=38;5;203:gw=38;5;227:gx=38;5;121:tr=38;5;203:tw=38;5;227:tx=38;5;121"
export LS_COLORS="di=38;5;212:ln=38;5;51:ex=38;5;121"

# Bat theme
export BAT_THEME="Monokai Extended"
