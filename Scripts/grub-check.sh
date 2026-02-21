#!/usr/bin/env bash

# Checks if expected GRUB menu entries are present in grub.cfg

GRUB_CFG="/boot/grub/grub.cfg"
GRUB_BTRFS_CFG="/boot/grub/grub-btrfs.cfg"

missing=()

# Read grub.cfg (try directly, fall back to sudo)
if [[ -r "$GRUB_CFG" ]]; then
    grub_content=$(cat "$GRUB_CFG")
else
    grub_content=$(sudo cat "$GRUB_CFG") || { echo "Error: cannot read $GRUB_CFG"; exit 1; }
fi

# Check for Arch Linux menu entry
if ! grep -qP "^menuentry\s+'Arch Linux'" <<< "$grub_content"; then
    missing+=("Arch Linux")
fi

# Check for Windows menu entry (os-prober generates these)
if ! grep -qP "^menuentry\s+'Windows" <<< "$grub_content"; then
    missing+=("Windows")
fi

# Check for Arch Linux snapshots (grub-btrfs submenu sourced from grub-btrfs.cfg)
if ! grep -qP "^submenu\s+" "$GRUB_BTRFS_CFG" 2>/dev/null; then
    missing+=("Arch Linux snapshots")
fi

if (( ${#missing[@]} == 0 )); then
    echo "All GRUB entries present."
    exit 0
fi

msg="Missing GRUB entries: ${missing[*]}"
echo "$msg"

# notify-send needs a display; handle running as root (e.g. from pacman hook)
if [[ "$EUID" -eq 0 ]]; then
    logged_in_user=$(logname 2>/dev/null)
    if [[ -n "$logged_in_user" ]]; then
        uid=$(id -u "$logged_in_user")
        sudo -u "$logged_in_user" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
            notify-send -u critical "GRUB Check" "$msg"
    fi
else
    notify-send -u critical "GRUB Check" "$msg"
fi
exit 1
