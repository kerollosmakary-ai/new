# Bubblegum MOTD — plain ANSI
if [ -n "$PS1" ] && [ -z "${BUBBLEGUM_QUIET:-}" ]; then
  P='\033[38;5;212m'
  H='\033[38;5;205m'
  C='\033[38;5;51m'
  M='\033[38;5;121m'
  U='\033[38;5;141m'
  Y='\033[38;5;227m'
  R='\033[0m'

  printf "\n"
  printf "${P}  ╭────────────────────────────────────────╮${R}\n"
  printf "${P}  │${H}  🍬  B U B B L E G U M   T E R M I N A L ${P}│${R}\n"
  printf "${P}  ╰────────────────────────────────────────╯${R}\n"
  printf "\n"
  printf "  ${C}▸${R} editor    ${M}micro${R}\n"
  printf "  ${C}▸${R} files     ${M}ranger${R}\n"
  printf "  ${C}▸${R} fuzzy     ${M}fzf${R}  ${U}·${R}  Ctrl+R history  ${U}·${R}  Ctrl+T files\n"
  printf "  ${C}▸${R} list      ${M}ll${R} ${M}la${R} ${M}lt${R}\n"
  printf "  ${C}▸${R} edit      ${M}edit-shell${R}  ${M}edit-aliases${R}\n"
  printf "\n"
fi
