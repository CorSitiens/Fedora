#!/bin/bash

# ==== Directory Setup ====
mkdir .config
mkdir .config/hypr
mkdir .config/mako
mkdir .config/rofi
mkdir .config/waybar
mkdir Apps
mkdir Documents
mkdir Documents/House
mkdir Documents/Fax
mkdir Documents/Taxes
mkdir Downloads
mkdir Pictures
mkdir Pictures/Screenshots
mkdir Pictures/Wallpaper

# ==== Base Programs Install ====
sudo tee -a /etc/dnf/dnf.conf > /dev/null <<EOD
fastestmirror=True
max_parallel_downloads=10
defaultyes=True
EOD

sudo dnf install -y \
arc-theme \
dnf-plugins-core \
grim \
hyprland \
input-remapper \
kitty \
mako \
rofi-wayland \
pavucontrol \
pipewire \
polkit-gnome \
thunar \
sddm \
slurp \
swaybg \
swayidle \
syncthing \
tar \
usbutils \
waybar \
wireplumber \
flatpak

# ==== Extras ====
# hyprland-devel \

# ==== Setup Flatpak Repository ====
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ==== Setup Login Manager ====
sudo systemctl enable sddm
sudo systemctl set-default graphical.target

# ==== Setup Input Remapper ====
sudo systemctl enable --now input-remapper

# ==== Setup GRUB ====
sudo tee /etc/default/grub > /dev/null <<EOG
GRUB_TIMEOUT=3
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rhgb amd_iommu=on iommu=pt quiet"
GRUB_DISABLE_RECOVERY="true"
GRUB_ENABLE_BLSCFG=true
EOG
sudo grub2-mkconfig -o /etc/grub2.cfg

# ==== Setup Rofi Config ====
sudo tee ~/.config/rofi/config.rasi > /dev/null <<EOR
@theme "/usr/share/rofi/themes/sidebar.rasi"
window {
    height: 100%;
}
configuration {
  display-drun: " ";
}
EOR

# ==== Set Dark Theme ====
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita-dark'

# ==== Setup Default Waybar Config ====
cp -r /etc/xdg/waybar ~/.config

# ==== Configure Firewall for Syncthing ====
sudo firewall-cmd --zone=public --add-service=syncthing --permanent
sudo firewall-cmd --reload

# ==== Setup Syncthing ====
sudo systemctl enable syncthing@user.service
sudo systemctl start syncthing@user.service

# ==== Brave Browser ====
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser -y

# ==== SDDM Config ====
sudo nano /etc/sddm.conf
# Session=hyprland.desktop
# DisplayServer=wayland

#EOF