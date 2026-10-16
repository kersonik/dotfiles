# ==============================================================================
#  POWERLEVEL10K INSTANT PROMPT (Musí zůstat úplně nahoře)
# ==============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# ==============================================================================
#  OH MY ZSH & THEME CONFIGURATION
# ==============================================================================

# Cesta k Oh My Zsh instalaci
export ZSH="$HOME/.oh-my-zsh"

# Aktivace tématu Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Aktivní pluginy
plugins=(
    extract 
    git 
    sudo 
    archlinux 
    zsh-autosuggestions 
    zsh-syntax-highlighting
)

# Inicializace Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Načtení uživatelské konfigurace Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# ==============================================================================
#  ENVIRONMENT VARIABLES
# ==============================================================================

export EDITOR='micro'
export QT_QPA_PLATFORMTHEME='kvantum'
export WP_SITES_PATH="/home/kersonik/.config/opencode/wp-sites.json"

# Rozšíření PATH o tvůj lokální bin
export PATH="$HOME/.local/bin:$PATH"


# ==============================================================================
#  ZSH SYNTAX HIGHLIGHTING STYLES
# ==============================================================================

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
#  ALIASES & CUSTOM FUNCTIONS
# ==============================================================================

# Tvůj nový týdenní čistící skript
alias clean='~/bordel/cleaner/sys-clean.sh'

# VPN school routes
function vpn-routes() {
    echo "🔧 Nastavuji VPN routing pro školní síť..."
    
    local VPN_GW="10.100.105.1"
    local VPN_IF="tun0"
    
    if ! ip link show "$VPN_IF" 2>/dev/null | grep -q "UP"; then
        echo "❌ $VPN_IF není aktivní"
        return 1
    fi
    
    # Školní IP adresy
    local SCHOOL_IPS=(
        "192.168.22.0/24"
        "10.55.10.0/24"
        "10.55.100.0/24"
        "10.55.101.0/24"
        "10.55.200.0/24"
        "10.56.10.0/24"
        "10.50.50.0/24"
        "10.100.100.0/24"
    )
    
    # Přidej routes (vyžaduje sudo)
    for route in "${SCHOOL_IPS[@]}"; do
        if sudo ip route add "$route" via "$VPN_GW" dev "$VPN_IF" metric 50 2>/dev/null; then
            echo "✅ Route přidán: $route"
        else
            echo "ℹ Route již existuje (nebo není potřeba přidávat): $route"
        fi
    done
    
    echo "✅ VPN routing nastaveno!"
    echo ""
    echo "📋 Aktuální routes:"
    ip route | grep "$VPN_GW"
}

# Funkce pro sluzby s rootem a display serverem

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

cd() {
	builtin cd "$@" && ls
}
export LS_COLORS="di=38;5;39:ex=38;5;46:fi=38;5;253"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
