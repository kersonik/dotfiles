# ==============================================================================
#  POWERLEVEL10K INSTANT PROMPT (Musí zůstat úplně nahoře)
# ==============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==============================================================================
#  ENVIRONMENT VARIABLES
# ==============================================================================
export EDITOR='micro'
export QT_QPA_PLATFORMTHEME='kvantum'
export WP_SITES_PATH="/home/kersonik/.config/opencode/wp-sites.json"
export PATH="$HOME/.local/bin:$PATH"
export GPG_TTY=$(tty)

# ==============================================================================
#  OH MY ZSH CONFIGURATION
# ==============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    extract 
    git 
    sudo 
    archlinux 
    zsh-autosuggestions 
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ==============================================================================
#  VISUALS & COLORS (LS_COLORS + SYNTAX HIGHLIGHTING)
# ==============================================================================
export LS_COLORS="di=38;5;39:ex=38;5;46:fi=38;5;253"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

declare -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES=(
    'function'        'fg=39'
    'command'         'fg=39'
    'alias'           'fg=39'
    'builtin'         'fg=39'
    'suffix-alias'    'fg=39'
    'precommand'      'fg=39'
    'hashed'          'fg=39'
    'invalid'         'fg=196'
    'unknown-token'   'fg=196'
    'reserved-word'   'fg=220'
)

# ==============================================================================
#  ALIASES & OVERRIDES
# ==============================================================================
alias clean='sys-clean'

cd() {
    builtin cd "$@" && ls
}

# Chytrá funkce ls (pokud dostane existující soubor, rovnou ho catne)
unalias ls 2>/dev/null
ls() {
    local last_arg="${@: -1}"
    if [ $# -gt 0 ] && [ -f "$last_arg" ]; then
        cat "$last_arg"
    else
        command ls --color=auto "$@"
    fi
}

# ==============================================================================
#  CUSTOM FUNCTIONS
# ==============================================================================
function vpn-routes() {
    echo "🔧 Nastavuji VPN routing pro školní síť..."
    
    local VPN_GW="10.100.105.1"
    local VPN_IF="tun0"
    
    if ! ip link show "$VPN_IF" 2>/dev/null | grep -q "UP"; then
        echo "❌ $VPN_IF není aktivní"
        return 1
    fi
    
    local SCHOOL_IPS=(
        "192.168.22.0/24" "10.55.10.0/24" "10.55.100.0/24"
        "10.55.101.0/24" "10.55.200.0/24" "10.56.10.0/24"
        "10.50.50.0/24" "10.100.100.0/24"
    )
    
    for route in "${SCHOOL_IPS[@]}"; do
        if sudo ip route add "$route" via "$VPN_GW" dev "$VPN_IF" metric 50 2>/dev/null; then
            echo "✅ Route přidán: $route"
        else
            echo "ℹ Route již existuje (nebo není potřeba přidávat): $route"
        fi
    done
    
    echo "✅ VPN routing nastaveno!\n📋 Aktuální routes:"
    ip route | grep "$VPN_GW"
}

function vpn() {
    local pidfile="/tmp/vpn_monitor.pid"
    case "${1:-}" in
        on)
            if [[ -f "$pidfile" ]] && kill -0 "$(<"$pidfile")" 2>/dev/null; then
                echo "VPN monitor is already running (PID $(<"$pidfile"))"
                return 1
            fi

            # Refresh sudo timestamp before moving to background
            sudo -v || return 1

            (
                while true; do
                    sudo nmcli -t -f NAME,STATE c | grep -q "^443:activated" || sudo nmcli c u 443 >/dev/null 2>&1
                    sleep 300
                done
            ) &
            echo "$!" > "$pidfile"
            echo "VPN monitor started (PID $!)"
            ;;
        off)
            if [[ ! -f "$pidfile" ]]; then
                echo "VPN monitor is not running"
            else
                # Kill in subshell to suppress shell job termination messages
                ( kill "$(<"$pidfile")" 2>/dev/null )
                rm -f "$pidfile"
                echo "VPN monitor stopped"
            fi
            sudo nmcli c d 443 >/dev/null 2>&1 && echo "VPN 443 disconnected" || echo "VPN 443 already disconnected"
            ;;
        *)
            echo "Usage: vpn {on|off}"
            return 1
            ;;
    esac
}

# Funkce pro GUI služby s rootem
function gsudo_zenmap() {
    xhost +si:localuser:root > /dev/null
    sudo zenmap "$@"
    xhost -si:localuser:root > /dev/null
}
alias zenmap='gsudo_zenmap'

function gsudo_better-control() {
    xhost +si:localuser:root > /dev/null
    sudo better-control "$@"
    xhost -si:localuser:root > /dev/null
}
alias better-control='gsudo_better-control'

# ==============================================================================
#  P10K CONFIGURATION (Načíst na konci)
# ==============================================================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
