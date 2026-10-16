# autobackup

Automatická záloha `~/dotfiles` na GitHub.

## Jak to funguje

- `dotfiles-autobackup.sh` udělá `git add -A`; pokud jsou změny, vytvoří
  commit `auto: záloha (<host>) <datum>` a pushne na `origin`.
- Když změny nejsou, neudělá **nic** (žádné prázdné commity).
- Timer ho spouští **každou hodinu** (`OnCalendar=hourly`), plus 10 min
  po startu. `Persistent=true` dohoní vynechaný běh.

## Instalace

```bash
systemctl --user daemon-reload
systemctl --user enable --now dotfiles-autobackup.timer
```

Stav:

```bash
systemctl --user list-timers dotfiles-autobackup.timer
journalctl --user -u dotfiles-autobackup.service -n 20
```

## Poznámky

- Credentials řeší `gh` (global git config:
  `credential.https://github.com.helper=!/usr/bin/gh auth git-credential`),
  takže push funguje i bez interaktivního terminálu.
- Auto-commit zahrnuje i nově přidané soubory; co nechceš zálohovat, dej do
  `.gitignore`.
- Commity vznikají jen při reálných změnách — nejde o "prázdné commity pro
  graf". Kdybys chtěl i ty, řekni.
# test 09:32:24
