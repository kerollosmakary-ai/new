export EDITOR="micro"
export VISUAL="micro"
export PAGER="less"
export MANPAGER="less -R"
mkdir -p ~/.config/micro
cat > ~/.config/micro/settings.json << 'MICRO'
{
    "colorscheme": "monokai",
    "cursorline": true,
    "mkparents": true,
    "tabsize": 4,
    "tabstospaces": true,
    "autosu": false,
    "savecursor": true,
    "saveundo": true,
    "scrollbar": true,
    "statusline": true
}
MICRO
