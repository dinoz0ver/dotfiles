#!/usr/bin/env bash

#restarting qs
systemctl --user restart qs

#changing wallpaper
#pkill hyprpaper
ln -sf "$(cat ~/.cache/wal/wal)" ~/.cache/wal/current_wallpaper
#hyprpaper >/dev/null 2>&1 &
#disown
pgrep -x hyprpaper >/dev/null || hyprpaper >/dev/null 2>&1 &
hyprctl hyprpaper wallpaper ",~/.cache/wal/current_wallpaper,cover"
#hyprctl hyprpaper preload ~/.cache/wal/current_wallpaper
#hyprctl hyprpaper wallpaper ,~/.cache/wal/current_wallpaper
#hyprctl hyprpaper preload "$(cat ~/.cache/wal/wal)"
#hyprctl hyprpaper wallpaper ,"$(cat ~/.cache/wal/wal)"

#changing colors in hyprlock
source ~/.cache/wal/colors.sh
tmpfile=$(mktemp)
cat > "$tmpfile" <<EOF
\$background_color = ${background#\#}
\$foreground_color = ${foreground#\#}
\$accent_color = ${color1#\#}
\$wallpaper = ${wallpaper}
EOF
cat ~/.config/hypr/hyprlock_template.conf >> "$tmpfile"
mv "$tmpfile" ~/.config/hypr/hyprlock.conf

sleep 1
notify-send "Wallpaper and colorscheme changed"
