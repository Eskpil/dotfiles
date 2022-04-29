#!/usr/bin/env bash

set -ex

ln -sf "$PWD/.bashrc" "$HOME/.bashrc"
ln -sf "$PWD/.bash_aliases" "$HOME/.bash_aliases"
ln -sf "$PWD/scripts" "$HOME/scripts"
ln -sf "$PWD/.vimrc" "$HOME/.vimrc"
ln -sf "$PWD/.config/alacritty/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"
ln -sf "$PWD/.config/sway/config" "$HOME/.config/sway/config"
