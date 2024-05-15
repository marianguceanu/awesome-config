#!/bin/sh
monitor_count=$(xrandr --listmonitors|awk '{print $2}'|head -n 1)
echo $monitor_count
if [ $monitor_count -eq 2 ]; then
	xrandr --output eDP --off --output HDMI-A-0 --primary --mode 1920x1080 --pos 1920x0 --rotate normal
	exit 0
fi
if [ $monitor_count -eq 1 ]; then
	is_monitor=$(xrandr --listmonitors | grep HDMI | awk '{print $4}')
	echo $is_monitor
	if [ "$is_monitor" == "HDMI-A-0" ]; then
		exit 0
	fi
fi
xrandr --output eDP --primary --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-A-0 --mode 1920x1080 --pos 1920x0 --rotate normal
