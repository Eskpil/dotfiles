#!/bin/sh

sudo pacman -S --needed git meson base-devel ninja xorg-xwayland

mkdir /tmp/build-34234
cd /tmp/build-34234

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..

git clone https://gitlab.freedesktop.org/wayland/wayland.git
cd wayland
meson build/ -Ddocumentation=false -Dtests=false
sudo ninja -C build/ install
cd ..

git clone https://gitlab.freedesktop.org/wlroots/wlroots.git
cd wlroots
meson build/ -Dxwayland=true
sudo ninja -C build/ install
cd ..

git clone https://github.com/swaywm/sway.git
cd sway
meson build/
sudo ninja -C build/ install
cd ..
