#!/usr/bin/env bash

# wallpaper picker menu for use with pywal - uses fzf+kitty for image preview, falls back to dmenu

FOLDER=~/Pictures/Wallpapers # wallpaper folder
SCRIPT=~/Scripts/pywal16.sh # script to run after wal for refreshing programs, etc.


menu () {
    if [[ "$TERM" == "xterm-kitty" ]]; then
        CHOICE=$(echo -e "Random\n$(command ls -v "$FOLDER")" | fzf \
            --layout=reverse \
            --height=100% \
            --prompt="Wallpaper: " \
            --preview="[[ {} == Random ]] && echo 'Pick a random wallpaper' || kitten icat --clear --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 $FOLDER/{}" \
            --preview-window=right:60%)
    elif command -v nsxiv >/dev/null; then
        CHOICE=$(nsxiv -otb "$FOLDER"/*)
    else
        CHOICE=$(echo -e "Random\n$(command ls -v "$FOLDER")" | dmenu -l 15 -i -p "Wallpaper: ")
    fi

case $CHOICE in
    Random) wal -i "$FOLDER" -o "$SCRIPT" --backend colorthief ;;
    /*) wal -i "$CHOICE" -o "$SCRIPT" --backend colorthief ;;
    *.*) wal -i "$FOLDER/$CHOICE" -o "$SCRIPT" --backend colorthief ;;
    *) exit 0 ;;
esac
}

case "$#" in
    0) menu ;;
    1) wal -i "$1" -o $SCRIPT ;;
    2) wal -i "$1" --theme $2 -o $SCRIPT ;;
    *) exit 0 ;;
esac
