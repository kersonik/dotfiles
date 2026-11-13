#!/usr/bin/env bash
# ==============================================================================
# OS-Independent Dotfiles Symlink & Config Deployer
# Works on any Linux / Unix / macOS distribution without package manager dependencies.
# ==============================================================================

set -e

# Terminal colors
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Resolve repository directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCH_DIR="$SCRIPT_DIR/arch"
TARGET_DIR="${TARGET_DIR:-$HOME}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${BACKUP_DIR:-$TARGET_DIR/.dotfiles-backup-$TIMESTAMP}"
DRY_RUN=false
FORCE=false

show_help() {
    cat <<EOF
${BOLD}Usage:${NC} $(basename "$0") [OPTIONS]

Safely deploys configuration symlinks from the dotfiles repository to \$HOME.
OS-independent: works on Arch, Ubuntu, Debian, Fedora, Alpine, macOS, etc.

${BOLD}Options:${NC}
  -d, --dry-run       Show actions that would be taken without modifying any files
  -f, --force         Proceed automatically without interactive prompts
  -b, --backup-dir    Specify custom backup directory (default: ~/.dotfiles-backup-<timestamp>)
  -t, --target        Target directory for dotfiles (default: \$HOME)
  -h, --help          Show this help message and exit

EOF
}

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -b|--backup-dir)
            BACKUP_DIR="$2"
            shift 2
            ;;
        -t|--target)
            TARGET_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}[Error] Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

if [ ! -d "$ARCH_DIR" ]; then
    echo -e "${RED}[Error] Configuration directory not found at $ARCH_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}${BOLD}=== Dotfiles Config Deployer (OS-Independent) ===${NC}"
echo -e "Source: ${BOLD}$ARCH_DIR${NC}"
echo -e "Target: ${BOLD}$TARGET_DIR${NC}"
[ "$DRY_RUN" = true ] && echo -e "${YELLOW}${BOLD}Mode:   DRY-RUN (No files will be modified)${NC}"

# Find available packages (directories inside arch/, ignoring install.sh)
PACKAGES=()
for d in "$ARCH_DIR"/*/; do
    [ -d "$d" ] || continue
    pkg="$(basename "$d")"
    PACKAGES+=("$pkg")
done

echo -e "Detected config packages: ${GREEN}${PACKAGES[*]}${NC}"
echo ""

# Function to safely create symlink and backup existing targets
link_leaf() {
    local src="$1"
    local dest="$2"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        # Check if already correctly linked
        if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
            echo -e "  ${GREEN}✓ Already linked:${NC} $dest -> $src"
            return 0
        fi

        # If it's a real file/dir (not a symlink), back it up
        if [ ! -L "$dest" ]; then
            if [ "$DRY_RUN" = true ]; then
                echo -e "  ${YELLOW}[DRY-RUN] Would backup:${NC} $dest -> $BACKUP_DIR/"
            else
                local rel_path="${dest#$TARGET_DIR/}"
                local backup_dest="$BACKUP_DIR/$rel_path"
                mkdir -p "$(dirname "$backup_dest")"
                cp -a "$dest" "$backup_dest"
                echo -e "  ${YELLOW}Backed up:${NC} $dest -> $backup_dest"
            fi
        fi

        if [ "$DRY_RUN" = true ]; then
            echo -e "  ${YELLOW}[DRY-RUN] Would remove old target:${NC} $dest"
        else
            rm -rf "$dest"
        fi
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${BLUE}[DRY-RUN] Would link:${NC} $dest -> $src"
    else
        mkdir -p "$(dirname "$dest")"
        ln -sfn "$src" "$dest"
        echo -e "  ${GREEN}Linked:${NC} $dest -> $src"
    fi
}

for pkg in "${PACKAGES[@]}"; do
    pkg_dir="$ARCH_DIR/$pkg"
    echo -e "${BOLD}Deploying package: $pkg${NC}"

    # Process all files/directories in package
    find "$pkg_dir" -mindepth 1 -maxdepth 1 | while read -r item; do
        item_name="$(basename "$item")"

        # Ignore package README and documentation files
        if [[ "$item_name" =~ ^README(\..+)?$ ]]; then
            continue
        fi

        # Special case 1: .config folder
        if [ "$item_name" = ".config" ] && [ -d "$item" ]; then
            for app_cfg in "$item"/*; do
                [ -e "$app_cfg" ] || continue
                app_name="$(basename "$app_cfg")"

                # If it's systemd user services, link unit files individually to avoid overwriting ~/.config/systemd
                if [ "$app_name" = "systemd" ] && [ -d "$app_cfg/user" ]; then
                    for unit in "$app_cfg/user"/*; do
                        [ -e "$unit" ] || continue
                        unit_name="$(basename "$unit")"
                        link_leaf "$unit" "$TARGET_DIR/.config/systemd/user/$unit_name"
                    done
                else
                    # Standard app configs (hypr, kitty, waybar, wofi, etc.) are linked as folders
                    link_leaf "$app_cfg" "$TARGET_DIR/.config/$app_name"
                fi
            done

        # Special case 2: .local/bin scripts
        elif [ "$item_name" = ".local" ] && [ -d "$item" ]; then
            if [ -d "$item/bin" ]; then
                for bin_file in "$item/bin"/*; do
                    [ -e "$bin_file" ] || continue
                    bin_name="$(basename "$bin_file")"
                    link_leaf "$bin_file" "$TARGET_DIR/.local/bin/$bin_name"
                done
            fi

        # Standard dotfiles at root (e.g. .zshrc, .p10k.zsh)
        else
            link_leaf "$item" "$TARGET_DIR/$item_name"
        fi
    done
done

echo ""
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}${BOLD}=== DRY-RUN Complete: No files were changed ===${NC}"
else
    echo -e "${GREEN}${BOLD}=== Configuration deployment finished successfully! ===${NC}"
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "Backups preserved in: ${BOLD}$BACKUP_DIR${NC}"
    fi
fi
