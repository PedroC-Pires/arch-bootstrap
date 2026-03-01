#!/bin/bash

# --- PRE-FLIGHT CHECKS ---
# Ensure the script is NOT run as root (makepkg will fail later otherwise)
if [ "$EUID" -eq 0 ]; then
    echo "!! Please do NOT run this script with sudo or as root !!"
    echo "The script will ask for your password when needed."
    exit 1
fi

# Exit on error
set -e

echo "== Starting Arch Linux Bootstrap =="

# Sudo keep-alive: Updates the timestamp and keeps it alive in the background
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "== Initial System Sync & Mirror Update =="
# Avoid partial upgrades: Sync and update everything first
sudo pacman -Syu --needed --noconfirm reflector git linux-headers

echo ">> Optimizing Mirrors..."
sudo reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

echo "== Optimizing pacman.conf =="
sudo sed -i '/#\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
sudo sed -i 's/^#ParallelDownloads = .*/ParallelDownloads = 10/' /etc/pacman.conf

# The most essential tweak
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
    sudo sed -i '/Color/a ILoveCandy' /etc/pacman.conf
fi

echo "== Detecting GPU and selecting drivers =="
# Using DKMS for Nvidia to ensure it works across all kernel types (LTS, Zen, etc)
GPU_DRIVERS=""
if lspci | grep -qi "vga .* nvidia"; then
    echo ">> Nvidia GPU detected (Using DKMS for kernel compatibility)."
    GPU_DRIVERS="nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings"
elif lspci | grep -qi "vga .* amd"; then
    echo ">> AMD GPU detected."
    GPU_DRIVERS="vulkan-radeon lib32-vulkan-radeon mesa lib32-mesa vulkan-tools"
elif lspci | grep -qi "vga .* intel"; then
    echo ">> Intel GPU detected."
    GPU_DRIVERS="vulkan-intel lib32-vulkan-intel mesa lib32-mesa"
fi

echo "== Installing official packages =="
sudo pacman -S --needed --noconfirm \
base-devel sudo nano wget curl htop btop unzip p7zip rsync man-db man-pages networkmanager \
kdeconnect okular kcalc ark \
mpv ffmpeg gstreamer gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav \
steam gamemode mangohud lib32-mangohud $GPU_DRIVERS \
lutris gamescope wine wine-mono wine-gecko samba \
npm nodejs python python-pip gcc pnpm deno typescript ripgrep fd clang cmake make docker docker-compose-plugin jq github-cli tmux \
ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono \
unrar xdg-utils \
flatpak flatpak-kcm timeshift fastfetch cups bluez bluez-utils \
discord obs-studio qbittorrent yt-dlp

echo "== Installing yay (AUR helper) =="
if ! command -v yay &> /dev/null; then
    _tmpdir=$(mktemp -d)
    cd "$_tmpdir"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf "$_tmpdir"
fi

echo "== Installing AUR packages =="
yay -S --needed --noconfirm \
google-chrome \
visual-studio-code-bin \
spotify-launcher \
protonup-qt \
corectrl \
vkbasalt \
heroic-games-launcher-bin

echo "== Enabling Services =="
sudo systemctl enable --now NetworkManager bluetooth cups docker

echo "== Wine & Desktop Integration =="
sudo mkdir -p /usr/local/share/applications
sudo tee /usr/local/share/applications/wine.desktop > /dev/null <<EOF
[Desktop Entry]
Type=Application
Name=Wine Windows Program Loader
Exec=wine start /progman %f
MimeType=application/x-ms-dos-executable;application/x-msi;application/x-ms-shortcut;
Icon=wine
NoDisplay=false
Categories=System;Emulator;
EOF

xdg-mime default wine.desktop application/x-ms-dos-executable
xdg-mime default wine.desktop application/x-msi

echo "== Final Tweaks =="
sudo usermod -aG docker $USER
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo tee /etc/sysctl.d/99-steam-gaming.conf > /dev/null <<EOF
fs.file-max = 2097152
vm.swappiness = 10
vm.max_map_count = 1048576
kernel.sched_migration_cost_ns = 5000000
EOF
sudo sysctl --system

echo "== Adding fastfetch to shell startup =="
# For Bash
if ! grep -q "fastfetch" ~/.bashrc; then
    echo -e "\n# Show system info on startup\nfastfetch" >> ~/.bashrc
fi

echo -e "\n== Bootstrap complete! =="

# --- REBOOT COUNTDOWN ---
echo "System will reboot in 5 seconds. Press any key to cancel..."
for i in {5..1}; do
    echo -ne "$i... "
    read -rsn1 -t 1 && { echo -e "\nReboot cancelled by user. Please reboot manually later."; exit 0; }
done

echo -e "\nRebooting now..."
sudo reboot