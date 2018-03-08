#!/usr/bin/env sh
DIS_MONITOR=$(xrandr | grep "connected [0-9]" | cut -d' ' -f 1)
# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

echo "$DIS_MONITOR"
# Launch bar1 and bar2
MONITOR=$DIS_MONITOR polybar top &
#如果你有其他显示器 , 请自行增加
#MONITOR=DP-1-1 polybar top &
MONITOR=$DIS_MONITOR polybar bottom &

echo "Bars launched..."
