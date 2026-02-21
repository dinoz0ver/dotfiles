#!/usr/bin/env bash
# Retry up to 2 times with 30-second timeout per request
for i in {1..2}; do
  text=$(curl -s --max-time 30 "https://wttr.in/$1?format=1")
  if [[ $? == 0 && -n "$text" ]]; then
    text=$(echo "$text" | sed -E "s/\s+/ /g")
    tooltip=$(curl -s --max-time 30 "https://wttr.in/$1?format=4")
    if [[ $? == 0 && -n "$tooltip" ]]; then
      tooltip=$(echo "$tooltip" | sed -E "s/\s+/ /g")
      echo "{\"text\":\"$text\", \"tooltip\":\"$tooltip\"}"
      exit 0
    fi
  fi
  sleep 1
done
echo "{\"text\":\"error\", \"tooltip\":\"error\"}"
exit 1
