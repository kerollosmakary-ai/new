# Fzf key bindings
if command -v fzf >/dev/null 2>&1; then
    FZF_BASE="$PREFIX/share/fzf"
    [ -f "$FZF_BASE/key-bindings.bash" ] && source "$FZF_BASE/key-bindings.bash"
    [ -f "$FZF_BASE/completion.bash" ]  && source "$FZF_BASE/completion.bash"
    export FZF_DEFAULT_OPTS="
        --height 40%
        --layout=reverse
        --border=rounded
        --color=fg:250,bg:236,hl:212
        --color=fg+:255,bg+:238,hl+:205
        --color=prompt:212,spinner:51,pointer:121,marker:227
        --color=info:245,border:141
        --prompt='❯ '
        --pointer='▶'
        --marker='✓'
    "
fi

# ble.sh — syntax highlighting + completion
if [ -f "$PREFIX/share/blesh/ble.sh" ]; then
    source "$PREFIX/share/blesh/ble.sh" --noattach
fi

# bash-completion
if [ -f "$PREFIX/share/bash-completion/bash_completion" ]; then
    source "$PREFIX/share/bash-completion/bash_completion"
fi
