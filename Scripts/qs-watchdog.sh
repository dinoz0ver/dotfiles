#!/bin/bash
# Quickshell watchdog — restarts on crash, sends notification

MAX_CRASHES=5
WINDOW=60
crashes=()

cleanup() { exit 0; }
trap cleanup SIGTERM SIGINT

while true; do
    qs
    code=$?

    # Clean exit — stop
    [[ $code -eq 0 ]] && break

    now=$(date +%s)
    signal=$((code - 128))

    # Rate limiting: track crashes within the window
    crashes+=("$now")
    # Prune old entries
    recent=()
    for t in "${crashes[@]}"; do
        (( now - t < WINDOW )) && recent+=("$t")
    done
    crashes=("${recent[@]}")

    if (( ${#crashes[@]} >= MAX_CRASHES )); then
        notify-send -u critical "Quickshell crashed" \
            "$MAX_CRASHES crashes in ${WINDOW}s — giving up."
        exit 1
    fi

    # Delayed notification (qs needs to restart first to receive it)
    (sleep 3 && notify-send -u critical "Quickshell crashed" \
        "Signal $signal (exit $code). Restarted automatically.") &

    sleep 1
done
