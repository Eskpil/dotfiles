#!/bin/bash

function run() {
  if ! pgrep $1; then
    $@ &
  fi
}

xrandr --output HDMI-0 --rotate left --left-of DP-0 --output DP-0 --primary

xsetroot -cursor_name left_ptr &

run picom &
run lxsession &
run redis-server &
run nitrogen --restore &
