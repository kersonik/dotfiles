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
    'function'        'fg=#00AFFF,bold'
    'command'         'fg=#00AFFF'
    'alias'           'fg=#00AFFF'
    'builtin'         'fg=#00AFFF'
    'suffix-alias'    'fg=#00AFFF'
    'precommand'      'fg=#00AFFF'
    'hashed'          'fg=#00AFFF'
    'invalid'         'fg=#C50B09'
    'unknown-token'   'fg=#C50B09'
    'reserved-word'   'fg=#00AFFF,standout'
)


# ==============================================================================
#  ALIASES & CUSTOM FUNCTIONS
# ==============================================================================

# Tvůj nový týdenní čistící skript
alias clean='~/bordel/cleaner/sys-clean.sh'

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
