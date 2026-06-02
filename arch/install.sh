#!/bin/zsh

# Colors for terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Starting dotfiles installation ===${NC}"

# 1. System check
if [ ! -f /etc/arch-release ]; then
    echo -e "${YELLOW}[Error] This script is intended for Arch Linux only.${NC}"
    exit 1
fi
echo -e "${GREEN}[Arch Linux detected]${NC}"
sudo pacman -Syu --needed --noconfirm stow hyprland kitty waybar wofi swaync zsh ttf-font-awesome unzip git curl swww micro hyprlock awww ncspot xdg-desktop-portal-hyprland polkit-kde-agent qt5-wayland qt6-wayland ttf-jetbrains-mono-nerd

# 2. Yay (AUR helper)
if ! command -v yay &>/dev/null; then
    echo -e "${GREEN}Installing yay...${NC}"
    sudo pacman -S --needed --noconfirm base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
fi

# 3. Oh My Zsh installation
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN}Installing Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 4. ZSH Plugins & Theme installation
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

echo -e "${GREEN}Installing ZSH Theme & Plugins...${NC}"
[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# 5. Wallpapers download
echo -e "${GREEN}Syncing Wallpapers...${NC}"
if [ ! -d "$HOME/Pictures/wallpapers/.git" ]; then
    rm -rf "$HOME/Pictures/wallpapers"
    mkdir -p "$HOME/Pictures/wallpapers"
    git clone https://github.com/kersonik/wallpapers.git "$HOME/Pictures/wallpapers"
fi

# 6. Backup (Interactive)
read -r -p "${YELLOW}Do you want to backup current config to \$HOME/config-backup? [y/N]: ${NC}" backup_choice
if [[ "$backup_choice" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Backing up...${NC}"
    mkdir -p "$HOME/config-backup/.config"
    for app in hypr hyprlock kitty waybar wofi swaync awww ncspot; do
        [ -d "$HOME/.config/$app" ] && [ ! -L "$HOME/.config/$app" ] && cp -r "$HOME/.config/$app" "$HOME/config-backup/.config/"
    done
    [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$HOME/config-backup/"
    [ -f "$HOME/.p10k.zsh" ] && [ ! -L "$HOME/.p10k.zsh" ] && cp "$HOME/.p10k.zsh" "$HOME/config-backup/"
fi

# 7. Aggressive cleanup
echo -e "${GREEN}Cleaning old configurations and symlinks...${NC}"
rm -rf "$HOME/.config/hypr" "$HOME/.config/hyprlock" "$HOME/.config/kitty" "$HOME/.config/waybar" "$HOME/.config/wofi" "$HOME/.config/swaync" "$HOME/.config/awww" "$HOME/.config/ncspot" "$HOME/.zshrc" "$HOME/.p10k.zsh"
for app in awww hypr hyprlock kitty ncspot swaync waybar wofi; do
    [ -L "$HOME/$app" ] && rm -f "$HOME/$app"
done

# 8. Stow execution
echo -e "${GREEN}Linking dotfiles via Stow...${NC}"
script_dir="$(dirname "$0")"
for dir in "$script_dir"/*/; do
    pkg="${dir%/}"
    pkg="${pkg##*/}"
    stow -d "$script_dir" -R -v -t "$HOME" "$pkg"
done

echo -e "${BLUE}=== Done! Start a new shell using 'zsh' ===${NC}"
