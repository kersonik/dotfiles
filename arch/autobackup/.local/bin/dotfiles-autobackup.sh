#!/usr/bin/env bash
# dotfiles-autobackup.sh — periodická záloha ~/dotfiles na GitHub.
#
# Commituje jen když existují reálné změny (žádné prázdné commity),
# takže historie zůstává smysluplná a slouží jako záloha.
# Spouští se z dotfiles-autobackup.timer (systemd --user).

set -euo pipefail

export PATH="/usr/local/bin:/usr/bin:/bin"
export GIT_TERMINAL_PROMPT=0

REPO="$HOME/dotfiles"
cd "$REPO" || { echo "Chyba: $REPO neexistuje"; exit 1; }

# Během rebase/merge nezasahovat.
if [[ -d .git/rebase-merge || -d .git/rebase-apply || -f .git/MERGE_HEAD ]]; then
    echo "Probíhá rebase/merge — přeskakuji."
    exit 0
fi

# Nezalomit se na rozepsaném index.lock z jiného gitu.
if [[ -f .git/index.lock ]]; then
    echo "index.lock existuje (jiný git běží?) — přeskakuji."
    exit 0
fi

git add -A

if git diff --cached --quiet; then
    # Žádné změny → nic k zálohování.
    exit 0
fi

HOST="$(hostname -s 2>/dev/null || echo host)"
git commit -q -m "auto: záloha ($HOST) $(date '+%Y-%m-%d %H:%M')"

# Push; při odmítnutí (nové commity na remote) zkus rebase a znovu.
if ! git push -q 2>/dev/null; then
    if git pull --rebase --autostash -q 2>/dev/null; then
        git push -q || { echo "Push selhal (síť?) — commit zůstává lokálně."; exit 1; }
    else
        echo "Rebase selhal — commit zůstává lokálně."
        exit 1
    fi
fi

echo "Záloha odeslána: $(git log --oneline -1)"
