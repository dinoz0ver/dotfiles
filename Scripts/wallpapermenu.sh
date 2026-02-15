#!/usr/bin/env bash

# slightly scuffed wallpaper picker menu for use with pywal - uses nsxiv if installed, otherwise uses dmenu

FOLDER=~/Pictures/Wallpapers # wallpaper folder
SCRIPT=~/Scripts/pywal16.sh # script to run after wal for refreshing programs, etc.


menu () {
    if command -v nsxiv >/dev/null; then 
        CHOICE=$(nsxiv -otb "$FOLDER"/*)
    else 
        CHOICE=$(echo -e "Random\n$(command ls -v "$FOLDER")" | dmenu -l 15 -i -p "Wallpaper: ")
	echo "$CHOICE"
    fi

case $CHOICE in
    Random) wal -i "$FOLDER" -o "$SCRIPT" --backend colorthief ;; # dmenu random option
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
