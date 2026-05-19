#!/bin/zsh

# Colors for terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Starting dotfiles installation ===${NC}"

# 1. System detection and package installation
if [ -f /etc/arch-release ]; then
    echo -e "${GREEN}[Arch Linux detected]${NC}"
    sudo pacman -S --needed --noconfirm stow hyprland kitty waybar wofi swaync zsh ttf-font-awesome unzip git curl swww
elif [ -f /etc/lsb-release ]; then
    echo -e "${GREEN}[Ubuntu detected]${NC}"
    sudo apt update
    sudo apt install -y stow zsh kitty git curl unzip
else
    echo -e "${YELLOW}[Unsupported OS] This script is optimized for Arch and Ubuntu.${NC}"
fi

# 2. Oh My Zsh installation
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN}Installing Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3. ZSH Plugins & Theme installation
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

echo -e "${GREEN}Installing ZSH Theme & Plugins...${NC}"
[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# 4. Wallpapers download
#echo -e "${GREEN}Syncing Wallpapers...${NC}"
#if [ ! -d "$HOME/Pictures/wallpapers/.git" ]; then
#    rm -rf ~/Pictures/wallpapers
#    mkdir -p ~/Pictures/wallpapers
#    git clone https://github.com/kersonik/wallpapers.git ~/Pictures/wallpapers
#fi

# 5. Backup (Interactive)
echo -ne "${YELLOW}Do you want to backup current config to ~/config-backup? [y/N]: ${NC}"
read -r backup_choice
if [[ "$backup_choice" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Backing up...${NC}"
    mkdir -p ~/config-backup/.config
    for app in hypr kitty waybar wofi swaync awww ncspot opencode; do
        [ -d "$HOME/.config/$app" ] && [ ! -L "$HOME/.config/$app" ] && cp -r "$HOME/.config/$app" ~/config-backup/.config/
    done
    [ -f ~/.zshrc ] && [ ! -L ~/.zshrc ] && cp ~/.zshrc ~/config-backup/
    [ -f ~/.p10k.zsh ] && [ ! -L ~/.p10k.zsh ] && cp ~/.p10k.zsh ~/config-backup/
fi

# 6. Aggressive cleanup
echo -e "${GREEN}Cleaning old configurations and symlinks...${NC}"
rm -rf ~/.config/{hypr,kitty,waybar,wofi,swaync,awww,ncspot,opencode} ~/.zshrc ~/.p10k.zsh
for app in awww hypr hyprlock kitty ncspot opencode swaync waybar wofi zsh install.sh; do
    [ -L "$HOME/$app" ] && rm -f "$HOME/$app"
done

# 7. Stow execution
echo -e "${GREEN}Linking dotfiles via Stow...${NC}"
cd ~/dotfiles/arch || exit
for dir in */; do
    stow -R -v -t ~ "${dir%/}"
done

echo -e "${BLUE}=== Done! Start a new shell using 'exec zsh' ===${NC}"
