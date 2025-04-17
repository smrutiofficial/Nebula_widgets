#!/bin/bash

# Path to your base Conky config
CONKY_TEMPLATE="$(dirname "$0")/conky.conf"
CONKY_TMP="/tmp/conky_dynamic.conf"

# File being watched for changes
WATCHED_FILE="$HOME/Nebula/colors.txt"

# CSS file with background color
css_file="$HOME/.config/gtk-4.0/gtk.css"

# Extract hex code from GTK theme
hex_code=$(sed -n '/^\.background {$/{
    N
    s/^\.background {\n  background-color: \(#[0-9a-fA-F]\{6\}\);/\1/p
}' "$css_file")

# Set font cache
export FONTCONFIG_PATH="$(dirname "$0")/font"
fc-cache -fv "$FONTCONFIG_PATH"

# Kill existing Conky
killall conky 2>/dev/null

# Generate images
bash "$HOME/Nebula/U143/scripts/replace_svg_colors.sh" "$hex_code"

# Compute the adjusted color
# Strip # and sanitize length to 6 characters max
# Compute the adjusted color
#raw_color=$(bash "$HOME/Nebula/U143/scripts/adjust_hex_color.sh" "$hex_code" 16 100 | tr -d '\n' | tr -d '#')


# Add the leading '#' back
temp_color=$(bash "$HOME/Nebula/U143/scripts/adjust_hex_color.sh" "$hex_code" 58 80 | tr -d '\n' | tr -d '#')
temp_color2=$(bash "$HOME/Nebula/U143/scripts/adjust_hex_color.sh" "$hex_code" 8 100 | tr -d '\n' | tr -d '#')

# Replace placeholder in template with real color
sed -e "s|\${color \$TEMP_COLOR}|\${color $temp_color}|g" \
    -e "s|\${color \$TEMP_COLOR2}|\${color $temp_color2}|g" \
    "$CONKY_TEMPLATE" > "$CONKY_TMP"



# Launch Conky with the modified config
conky -c "$CONKY_TMP" &

echo "Initial Conky launched. Watching: $WATCHED_FILE"

# Watch for changes
while inotifywait -e modify "$WATCHED_FILE"; do
    echo "Change detected in $WATCHED_FILE"

    sleep 2

    # Update image again
    bash "$HOME/Nebula/U143/scripts/replace_svg_colors.sh" "$hex_code"

    killall conky 2>/dev/null

    sleep 8

    # Regenerate temp config with latest color
    temp_color=$(bash "$HOME/Nebula/U143/scripts/adjust_hex_color.sh" "$hex_code" 16 100 | tr -d '\n')
    sed "s|\$TEMP_COLOR|$temp_color|g" "$CONKY_TEMPLATE" > "$CONKY_TMP"

    conky -c "$CONKY_TMP" &
done
