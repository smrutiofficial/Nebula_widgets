#!/bin/bash

# Paths
COLOR_FILE="$HOME/Nebula/colors.txt"
SVG_PATH="$HOME/Nebula/U143/conky_data/cpalate.svg"
MODIFIED_SVG="$HOME/Nebula/U143/modified.svg"
OUTPUT_PNG="$HOME/Nebula/U143/conky_data/cpalate.png"

# Check if files exist
if [ ! -f "$SVG_PATH" ]; then
    echo "❌ SVG file not found at $SVG_PATH"
    exit 1
fi

if [ ! -f "$COLOR_FILE" ]; then
    echo "❌ Color file not found at $COLOR_FILE"
    exit 1
fi

# Read up to 8 colors from the color file, strip #ff prefix and re-add #
mapfile -t colors < <(grep -E '^#' "$COLOR_FILE" | head -n 8 | sed 's/^#ff/#/')

# Rect IDs to update
ids=(rect9 rect8 rect7 rect6 rect5 rect4 rect3 rect2)

# Copy original SVG
cp "$SVG_PATH" "$MODIFIED_SVG"

# Replace only the fill inside style=""
for i in "${!ids[@]}"; do
    id="${ids[$i]}"
    color="${colors[$i]}"

    if [ -z "$color" ]; then
        echo "⚠️ No color for ID: $id, skipping..."
        continue
    fi

    echo "🔁 Replacing fill color with $color for ID: $id"

    # Search for line with id="..." and next line with style="fill:..." and replace just the fill value
#sed -i "/id=\"$id\"/,/style=/ s/fill:#[0-9a-fA-F]\{6\}/fill:$color/" "$MODIFIED_SVG"

awk -v id="$id" -v color="$color" '
BEGIN { found = 0 }
{
    if ($0 ~ "id=\""id"\"") found = 1
    if (found && $0 ~ /fill="#[0-9a-fA-F]{6}"/) {
        sub(/fill="#[0-9a-fA-F]{6}"/, "fill=\"" color "\"")
        found = 0
    }
    print
}' "$MODIFIED_SVG" > "${MODIFIED_SVG}.tmp" && mv "${MODIFIED_SVG}.tmp" "$MODIFIED_SVG"

    echo "✅ Modified: $id"
done

# Convert the modified SVG to PNG
cairosvg "$MODIFIED_SVG" -o "$OUTPUT_PNG"

echo "✅ PNG saved to $OUTPUT_PNG"

