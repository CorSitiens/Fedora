#!/bin/bash

# ==== Directory Setup ====
mkdir .config
mkdir .config/bspwm
mkdir .config/sxhkd
mkdir .config/polybar
mkdir .config/picom
mkdir Apps
mkdir Documents
mkdir Documents/House
mkdir Documents/Fax
mkdir Documents/Obsidian
mkdir Documents/Taxes
mkdir Downloads
mkdir Pictures
mkdir Pictures/Wallpaper

# ==== Base Programs Install ====
sudo tee -a /etc/dnf/dnf.conf > /dev/null <<EOC
fastestmirror=True
max_parallel_downloads=10
defaultyes=True
EOC
sudo dnf install \
-y \
@base-x \
dnf-plugins-core \
kitty \
rofi \
thunar \
lightdm \
bspwm \
sxhkd \
polybar \
picom \
syncthing \
flatpak
# sudo dnf copr enable emixampp/synology-drive
# sudo dnf --refresh install synology-drive-noextra

# ==== Setup Flatpak Repository ====
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ==== Setup Window Manager Basics ====
sudo systemctl enable lightdm
sudo systemctl set-default graphical.target

cp /usr/share/doc/bspwm/examples/bspwmrc .config/bspwm
tee ~/.config/bspwm/bspwmrc > /dev/null <<EOD
#!/usr/bin/sh

sxhkd &

bspc monitor -d 1 2 3 4 5

bspc config border_width	2
bspc config window_gap		2

bspc config split_ratio			0.50
bspc config borderless_monocle	true
bspc config gapless_monocle		true
EOD
cp /usr/share/doc/bspwm/examples/sxhkdrc .config/sxhkd
tee -a ~/.config/sxhkd/sxhkdrc > /dev/null <<EOE

#temporary commands
super + x
	kitty
	
super + e
	thunar
	
super + BackSpace
	rofi -show drun -show-icons -disable-history
EOE
cp /etc/polybar/config.ini .config/polybar/
touch .config/polybar/launch.sh
chmod +x .config/polybar/launch.sh
tee -a ~/.config/polybar/launch.sh > /dev/null <<EOF
#!/usr/bin/env bash

# Terminate already running bar instances if all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

# Launch bar1 and bar2
echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
polybar bar1 2>&1 | tee -a /tmp/polybar1.log & disown
polybar bar2 2>&1 | tee -a /tmp/polybar2.log & disown

echo "Bars launched..."
EOF

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
#sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Configure Firewall for Syncthing
sudo firewall-cmd --zone=public --add-service=syncthing --permanent
sudo firewall-cmd --reload

# Brave
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser -y

# LightDM
sudo nano /etc/lightdm/lightdm.conf

#EOF