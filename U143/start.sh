#!/bin/bash

# Path to the file you want to watch
WATCHED_FILE="$HOME/Nebula/colors.txt"

# Set FontConfig path
export FONTCONFIG_PATH="$(dirname "$0")/font"
fc-cache -fv "$FONTCONFIG_PATH"

# Kill any running conky
killall conky 2>/dev/null
# Update the image
bash "$HOME/Nebula/U143/scripts/replace_svg_colors.sh"
# Start conky initially
conky -c "$(dirname "$0")/conky.conf" &

echo "Initial Conky launched. Watching: $WATCHED_FILE"

# Watch the file for MODIFY event
while inotifywait -e modify "$WATCHED_FILE"; do
    echo "Change detected in $WATCHED_FILE"

    # Optional: give time for changes to fully apply
   sleep 2

    # Update the image
bash "$HOME/Nebula/U143/scripts/replace_svg_colors.sh"

    # Kill any running conky
    killall conky 2>/dev/null

    # Optional: give time for changes to fully apply
    sleep 1

    # Restart conky
    conky -c "$(dirname "$0")/conky.conf" &
done

