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
sudo dnf install \
-y \
@base-x \
kitty \
rofi \
thunar \
lightdm \
slick-greeter \
bspwm \
sxhkd \
polybar \
picom
sudo dnf copr enable emixampp/synology-drive
sudo dnf --refresh install synology-drive-noextra

# ==== Setup Window Manager Basics ====
sudo systemctl enable lightdm
sudo systemctl set-default graphical.target

cp /usr/share/doc/bspwm/examples/bspwmrc .config/bspwm
cp /usr/share/doc/bspwm/examples/sxhkdrc .config/sxhkd
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