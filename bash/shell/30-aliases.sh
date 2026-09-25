# Detect eza or exa
if command -v eza >/dev/null 2>&1; then
    LS_CMD=eza
elif command -v exa >/dev/null 2>&1; then
    LS_CMD=exa
else
    LS_CMD=ls
fi

alias ll="$LS_CMD -lh --group-directories-first --icons 2>/dev/null || $LS_CMD -lh"
alias la="$LS_CMD -lah --group-directories-first --icons 2>/dev/null || $LS_CMD -lah"
alias lt="$LS_CMD --tree --level=2 --icons 2>/dev/null || tree -L 2"
alias l="$LS_CMD -lh"

# File ops
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

# Git
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --all --decorate'
alias gd='git diff'

# Termux
alias update='pkg update && pkg upgrade -y'
alias clean='pkg clean && rm -rf ~/.cache/*'
alias reload='source ~/.bashrc'
alias edit='micro ~/.bashrc'

# Ranger
alias r='ranger'

# Quick edits
alias edit-shell='micro ~/.config/shell/'
alias edit-aliases='micro ~/.config/shell/30-aliases.sh'
alias edit-colors='micro ~/.config/shell/00-colors.sh'

# System
alias ports='for f in /proc/net/tcp /proc/net/tcp6; do [ -r "$f" ] && tail -n +2 "$f" | awk "\$4==\"0A\"{print \$2}"; done | sort -u'
alias jobs='jobs -l'

# Fun
alias weather='curl -s "wttr.in/?format=3"'
alias cht='cht.sh'

# bat instead of cat
command -v bat >/dev/null && alias cat='bat --paging=never'
