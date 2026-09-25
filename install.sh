#!/usr/bin/env bash
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"

echo "[*] Installing Bubblegum Terminal from $REPO"

mkdir -p ~/.config ~/bin

# bashrc
ln -sf "$REPO/bash/bashrc" ~/.bashrc

# shell configs
mkdir -p ~/.config/shell
for f in "$REPO"/bash/shell/*.sh; do
  ln -sf "$f" ~/.config/shell/$(basename "$f")
done

# editor + file manager
[ -d "$REPO/bash/micro" ]  && ln -sfn "$REPO/bash/micro"  ~/.config/micro
[ -d "$REPO/bash/ranger" ] && ln -sfn "$REPO/bash/ranger" ~/.config/ranger

echo "[✓] Done. Reload with: source ~/.bashrc"
