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
kitty \
rofi \
thunar \
lightdm \
bspwm \
sxhkd \
polybar \
picom
sudo dnf copr enable emixampp/synology-drive
sudo dnf --refresh install synology-drive-noextra

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

sudo nano /etc/lightdm/lightdm.conf

#EOF