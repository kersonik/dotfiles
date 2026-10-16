# vpn-routes

Statické routy pro školní síť přes OpenVPN (`tun0`, brána `10.100.105.1`).

## Kanonický skript

`~/.local/bin/vpn-routes.sh` — **jediný zdroj pravdy** (seznam sítí i logika).
Všechny ostatní vstupní body ho volají, aby nedocházelo k rozcházení:

| Vstupní bod | Jak volá |
| :--- | :--- |
| zsh funkce `vpn-routes` (v `arch/zsh/.zshrc`) | `vpn-routes.sh up` |
| `~/.local/bin/15-vpn-routes` (NM dispatcher) | `vpn-routes.sh up` / `down` |
| `vpn-school-routes.service` (systemd --user) | `vpn-routes.sh up` |

Použití:

```bash
vpn-routes.sh        # přidá routy (up)
vpn-routes.sh up     # totéž
vpn-routes.sh down   # odstraní routy
```

Skript se při spuštění jako běžný uživatel sám pře-spustí přes `sudo`
(pokud je `sudo` dostupné). Pod rootem (NM dispatcher) běží přímo.

## Instalace systémových částí

Stow nainstaluje uživatelské soubory (`~/.local/bin`, `~/.config/systemd/user`).
Systémové věci je potřeba doinstalovat ručně:

```bash
# NetworkManager dispatcher hook (automatické routy při připojení VPN)
sudo install -m 755 ~/.local/bin/15-vpn-routes /etc/NetworkManager/dispatcher.d/15-vpn-routes

# systemd --user unit
systemctl --user daemon-reload
systemctl --user enable --now vpn-school-routes.service
```

## Poznámky

- `10.100.105.0/24` se záměrně neroutuje — je to vlastní tunelová podsíť
  (brána `10.100.105.1` v ní leží).
- `vpn-school-routes.service` běží jako **user** unit; pro neinteraktivní
  spuštění potřebuje buď běžet jako systémový unit, nebo mít NOPASSWD sudo
  pro `vpn-routes.sh`. Alternativou je NM dispatcher hook výše, který běží
  jako root přímo.
