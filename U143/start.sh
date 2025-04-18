#!/bin/bash

CONKY_TEMPLATE="$(dirname "$0")/conky.conf"
CONKY_TMP="/tmp/conky_dynamic.conf"
css_file="$HOME/.config/gtk-4.0/gtk.css"
COLOR_FILE="$HOME/Nebula/colors.txt"

export FONTCONFIG_PATH="$(dirname "$0")/font"
fc-cache -fv "$FONTCONFIG_PATH"

# Function to extract a valid hex code
get_valid_hex_code() {
    local attempts=5
    local delay=0.5
    local hex=""

    for ((i=1; i<=attempts; i++)); do
        sleep "$delay"
        hex=$(sed -n '/^\.background {$/{
            N
            s/^\.background {\n  background-color: \(#[0-9a-fA-F]\{6\}\);/\1/p
        }' "$css_file")

        if [[ $hex =~ ^#[0-9a-fA-F]{6}$ ]]; then
            echo "$hex"
            return
        fi
    done

    echo ""
}

# Function to launch/relaunch conky
update_conky() {
    hex_code=$(get_valid_hex_code)

    if [[ -z "$hex_code" ]]; then
        echo "❌ Hex code not found. Aborting update."
        return
    fi

    echo "🎨 Using hex color: $hex_code"

    temp_color=$(bash "$HOME/Nebula/U143/scripts/adjust_hex_color.sh" "$hex_code" 58 80 | tr -d '\n' | tr -d '#')
    temp_color2=$(bash "$HOME/Nebula/U143/scripts/adjust_hex_color.sh" "$hex_code" 8 100 | tr -d '\n' | tr -d '#')

    [[ -z "$temp_color" ]] && temp_color="${hex_code:1}"
    [[ -z "$temp_color2" ]] && temp_color2="${hex_code:1}"

    # Replace placeholders
    sed -e "s|\${color \$TEMP_COLOR}|\${color $temp_color}|g" \
        -e "s|\${color \$TEMP_COLOR2}|\${color $temp_color2}|g" \
        "$CONKY_TEMPLATE" > "$CONKY_TMP"

    # Refresh SVGs
    bash "$HOME/Nebula/U143/scripts/replace_svg_colors.sh" "$hex_code"

    # Restart Conky
    killall conky 2>/dev/null
    sleep 1.5
    conky -D -c "$CONKY_TMP" &
    echo "✅ Conky updated and relaunched"
}

# First-time launch
update_conky
echo "👁️  Watching for changes: $COLOR_FILE"

# Watch loop
while inotifywait -e close_write "$COLOR_FILE"; do
    echo "📦 Colors modified. Reloading..."
    sleep 2
    update_conky
done
