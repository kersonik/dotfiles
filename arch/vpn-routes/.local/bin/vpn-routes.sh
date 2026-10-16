#!/usr/bin/env bash
# vpn-routes.sh — správa statických rout pro školní síť přes OpenVPN (tun0)
#
# Kanonický skript (single source of truth). Ostatní vstupní body
# (zsh funkce, systemd unit, NetworkManager dispatcher) volají tento soubor.
#
# Použití:
#   vpn-routes.sh up      # přidá routy (výchozí)
#   vpn-routes.sh down    # odstraní routy
#
# Vyžaduje root. Pokud se spustí jako běžný uživatel a je dostupné sudo,
# automaticky se přes sudo pře-spustí.

set -euo pipefail

VPN_GATEWAY="10.100.105.1"
VPN_INTERFACE="tun0"
METRIC=50

# Sítě dostupné přes školní VPN.
# POZN: 10.100.105.0/24 se záměrně neuvádí — je to vlastní tunelová
# podsíť (brána 10.100.105.1 v ní leží), takže routa "skrz sebe" nedává smysl.
SCHOOL_ROUTES=(
    "192.168.22.0/24"    # hlavní servery
    "10.55.10.0/24"
    "10.55.100.0/24"
    "10.55.101.0/24"
    "10.55.200.0/24"
    "10.56.10.0/24"
    "10.50.50.0/24"
    "10.100.100.0/24"
)

ACTION="${1:-up}"

if [[ "$ACTION" != "up" && "$ACTION" != "down" ]]; then
    echo "Použití: $0 [up|down]" >&2
    exit 2
fi

# Pře-spuštění pod rootem, pokud nejsme root a máme sudo.
if [[ "$(id -u)" -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
        exec sudo -- "$0" "$ACTION"
    fi
    echo "Chyba: skript vyžaduje root (spusť přes sudo)." >&2
    exit 1
fi

if ! ip link show "$VPN_INTERFACE" 2>/dev/null | grep -q "UP"; then
    echo "$VPN_INTERFACE není aktivní — routy se neupravují."
    exit 1
fi

case "$ACTION" in
    up)
        echo "🔧 Přidávám školní routy přes $VPN_INTERFACE..."
        for route in "${SCHOOL_ROUTES[@]}"; do
            if ip route show "$route" 2>/dev/null | grep -q "$VPN_GATEWAY"; then
                echo "  ℹ $route (už existuje)"
            elif ip route add "$route" via "$VPN_GATEWAY" dev "$VPN_INTERFACE" metric "$METRIC"; then
                echo "  ✅ $route"
            else
                echo "  ⚠️  $route (chyba při přidávání)" >&2
            fi
        done
        ;;
    down)
        echo "🧹 Odstraňuji školní routy..."
        for route in "${SCHOOL_ROUTES[@]}"; do
            if ip route del "$route" via "$VPN_GATEWAY" dev "$VPN_INTERFACE" 2>/dev/null; then
                echo "  ✅ $route"
            fi
        done
        ;;
esac

echo "✅ Hotovo."
echo ""
echo "📋 Aktuální routy přes $VPN_GATEWAY:"
ip route | grep "$VPN_GATEWAY" || echo "  (žádné)"
