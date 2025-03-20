#!/bin/bash

current_time=$(date +%s)
target_time=$(date -d "07:40" +%s)

if [ $current_time -ge $target_time ]; then
    target_time=$(date -d "tomorrow 07:00" +%s)
fi

remaining_seconds=$((target_time - current_time))

while [ $remaining_seconds -gt 0 ]; do
    hours=$((remaining_seconds / 3600))
    minutes=$(( (remaining_seconds % 3600) / 60 ))
    seconds=$((remaining_seconds % 60))

    printf "\rTiempo que falta: %02d:%02d:%02d" $hours $minutes $seconds

    sleep 1
    remaining_seconds=$((remaining_seconds - 1))
done

echo -e "\nIt's over"
