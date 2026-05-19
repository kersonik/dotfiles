# kersonik's Dotfiles

Complete configuration for Arch Linux focused on a modern, fast, and visually clean environment powered by Wayland (Hyprland) and the Zsh shell.

## Component Overview

| Component | Tool | Description |
| :--- | :--- | :--- |
| **Window Manager** | Hyprland | Dynamic tiling window manager for Wayland with fluid animations. |
| **Shell** | Zsh + Powerlevel10k | Highly productive terminal environment using the p10k theme. |
| **Bar / Panel** | Waybar | Extensively customizable status bar (includes multiple themes). |
| **Launcher** | Wofi | Application launcher and menu for switching themes/wallpapers. |
| **Terminal** | Kitty | GPU-accelerated terminal emulator supporting ligatures and tabs. |
| **Lockscreen** | Hyprlock | Modern lockscreen with integrated music, weather, and battery widgets. |
| **Notifications** | Swaync | Notification Center featuring a clean graphical control panel. |
| **Music** | ncspot | Native terminal Spotify client written in Rust. |
| **Wallpapers** | awww / swww | Custom automated system for wallpaper management and rotation. |

## Repository Structure

Configurations are cleanly organized by package inside the `arch/` directory. The root contains your setup files and repository metadata:

```plaintext
~/dotfiles/
├── .config/               # System symlinks pointing to the arch/ directory
│   ├── hypr -> ../arch/hypr/.config/hypr
│   ├── kitty -> ../arch/kitty/.config/kitty
│   └── ...
├── arch/                  # Source configurations divided by application
│   ├── awww/              # Wallpaper daemon states
│   ├── hypr/              # Main Hyprland and workspace setup
│   ├── hyprlock/          # Lockscreen layouts, appearance, and indicator scripts
│   ├── kitty/             # Terminal profiles and font settings
│   ├── ncspot/            # Terminal Spotify configuration
│   ├── swaync/            # Notification Center styles and refresh tools
│   ├── waybar/            # Waybar modules and themes (default, line, zen, experimental)
│   ├── wofi/              # Application launcher styling and dynamic menus
│   └── zsh/               # Comprehensive .zshrc and Powerlevel10k definitions
├── .gitignore             # Block tracking of dynamic states (current-wallpaper, etc.)
└── README.md              # This documentation
```

## Installation and Deployment

**IMPORTANT:** Before running the installer, ensure that `git` is available on your system. Sensitive deployment files (e.g., active passwords or tokens for tools like opencode) must never be added here; store them directly and securely in `~/.config/opencode/wp-sites.json`.

### 1. Clone the Repository
Clone the repository straight into your home directory:
```bash
git clone [https://github.com/kersonik/dotfiles.git](https://github.com/kersonik/dotfiles.git) ~/dotfiles
cd ~/dotfiles
```

### 2. Run the Installation Script
Execute the bundled deployment script located inside the `arch/` folder. The script safely:
*   Backs up any conflicting active configurations to `~/config-backup` (if you choose `y`).
*   Generates clean symlinks using GNU Stow from `~/dotfiles/arch/...` into your system's `~/.config/` directory.

```bash
chmod +x arch/install.sh
./arch/install.sh
```

## Features & Automation Scripts

### Wallpaper Rotation (awww & wofi)
The setup is built around seamless backdrop changes that interact cleanly with Wayland utilities:
*   **Automation:** `arch/hypr/.config/hypr/wallpaper-rotate.sh` handles periodic swapping out of images.
*   **Menus:** Call up custom `wofi` dialogue configurations to pick specific graphics styles or swap out desktop bar arrangements on the fly.

### Feature-Rich Lockscreen (hyprlock)
The `arch/hyprlock/.config/hyprlock/` path provides data harvesting scripts inside the `scripts/` folder:
*   `weather.sh` - Fetches live weather conditions via API.
*   `battery.sh` - Monitors power levels (optimized for laptop setups like the HP EliteBook).
*   `music.sh` & `music-progress.sh` - Pulls current track details and metadata timelines directly from runtime players (such as ncspot).
*   **Layouts:** Features 20 distinct design files inside `layouts/`. Simply point your global `hyprlock.conf` to your preferred template to change styles.

### Waybar Themes
Quickly swap out status bar configurations using the internal `select.sh` control tool:
*   **default** - Traditional layout featuring system trays, resource monitors, and standard widgets.
*   **line** - Sleek, low-profile linear status panel.
*   **zen** - Focused distraction-free workspace mode.
*   **experimental** - Development environment containing upcoming custom modules.

## Security & Git Best Practices

This environment is maintained with security and transparency in mind:
*   **Zero Credential Tracking:** All private API tokens, database keys, and configuration profiles featuring cleartext entries are safely managed locally outside the repository context within system paths (`~/.config/`).
*   **Clean History Management:** Volatile runtime variables that mutate automatically (e.g., cached image fields, wallpaper-state) are properly mapped inside `.gitignore` to prevent polluted tracking trees.

---
*Maintained by kersonik (Arch Linux | WM: Hyprland | Shell: Zsh)*
