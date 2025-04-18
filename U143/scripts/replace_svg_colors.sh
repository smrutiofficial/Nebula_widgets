#!/bin/bash
# Get the first argument (hex color code)
new_color="$1"
# Paths
COLOR_FILE="$HOME/Nebula/colors.txt"
# colour pallete
SVG_PATH="$HOME/Nebula/U143/conky_data/cpalate.svg"
MODIFIED_SVG="$HOME/Nebula/U143/modified.svg"
OUTPUT_PNG="$HOME/Nebula/U143/conky_data/cpalate.png"
# background svg
BOX1_SVG="$HOME/Nebula/U143/conky_data/box1.svg"
BOX2_SVG="$HOME/Nebula/U143/conky_data/box2.svg"
BOX3_SVG="$HOME/Nebula/U143/conky_data/box3.svg"
BOX5_SVG="$HOME/Nebula/U143/conky_data/box5.svg"
# modify svg
MBOX1_SVG="$HOME/Nebula/U143/conky_data/mbox1.svg"
MBOX2_SVG="$HOME/Nebula/U143/conky_data/mbox2.svg"
MBOX3_SVG="$HOME/Nebula/U143/conky_data/mbox3.svg"
MBOX5_SVG="$HOME/Nebula/U143/conky_data/mbox5.svg"
# output png
BOX1_PNG="$HOME/Nebula/U143/conky_data/box1.png"
BOX2_PNG="$HOME/Nebula/U143/conky_data/box2.png"
BOX3_PNG="$HOME/Nebula/U143/conky_data/box3.png"
BOX5_PNG="$HOME/Nebula/U143/conky_data/box5.png"


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
ids=(rect9 rect8 rect7 rect6 rect5 rect4 rect3 rect2 rect1)

# Copy original SVG
cp "$SVG_PATH" "$MODIFIED_SVG"
bgclo=$(bash "$HOME/Nebula/U143/scripts/adjust_hex_color.sh" "$new_color" 30 20 | tr -d '\n')

# Replace only the fill inside style=""
for i in "${!ids[@]}"; do
    id="${ids[$i]}"

    if [ "$id" = "rect1" ]; then
        color="$bgclo"
    else
        color="${colors[$i]}"
    fi

    if [ -z "$color" ]; then
        echo "⚠️ No color for ID: $id, skipping..."
        continue
    fi

    echo "🔁 Replacing fill color with $color for ID: $id"

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
# Precompute adjusted colors using the script
color=$(bash "$HOME/Nebula/U143/scripts/adjust_hex_color.sh" "$new_color" 30 20 | tr -d '\n')
color2=$(bash "$HOME/Nebula/U143/scripts/adjust_hex_color.sh" "$color" 16 100 | tr -d '\n')
color3=$(bash "$HOME/Nebula/U143/scripts/adjust_hex_color.sh" "$color" 58 80 | tr -d '\n')
color4=$(bash "$HOME/Nebula/U143/scripts/adjust_hex_color.sh" "$color" 66 73 | tr -d '\n')

# Copy original SVG3 ============================================
cp "$BOX3_SVG" "$MBOX3_SVG"
awk -v color1="$color" -v color2="$color2" -v color3="$color3" -v color4="$color4" '
/id="rect5"/ { found = "color1" }
/id="rect3"/ { found = "color2" }
/id="rect4"/ { found = "color3" }
/id="rect15"/ { found = "color4" }
{
    if (found && /style=/) {
        sub(/fill:#[0-9a-fA-F]{6}/, "fill:" (found == "color1" ? color1 : (found == "color2" ? color2 : (found == "color3" ? color3 : color4))))
        found = ""
    }
    print
}
' "$MBOX3_SVG" > "${MBOX3_SVG}.tmp" && mv "${MBOX3_SVG}.tmp" "$MBOX3_SVG"

echo "🔁 Replacing fill color with $color"
echo "🔁 Replacing fill color with $color2"
echo "🔁 Replacing fill color with $color3"
echo "🔁 Replacing fill color with $color4"
cairosvg "$MBOX3_SVG" -o "$BOX3_PNG"
echo "✅ PNG saved to $BOX3_PNG"

# Copy original SVG2 ============================================
cp "$BOX2_SVG" "$MBOX2_SVG"
awk -v color="$color" '
/id="rect2"/ { found = 1 }
found && /fill:#/ {
    sub(/fill:#[0-9a-fA-F]{6}/, "fill:" color)
    found = 0
}
{ print }
' "$MBOX2_SVG" > "${MBOX2_SVG}.tmp" && mv "${MBOX2_SVG}.tmp" "$MBOX2_SVG"
echo "🔁 Replacing fill color with $new_color"
cairosvg "$MBOX2_SVG" -o "$BOX2_PNG"
echo "✅ PNG saved to $BOX2_PNG"

# Copy original SVG1 ==============================================
cp "$BOX1_SVG" "$MBOX1_SVG"
awk -v color="$color" '
/id="rect1"/ { found = 1 }
found && /fill:#/ {
    sub(/fill:#[0-9a-fA-F]{6}/, "fill:" color)
    found = 0
}
{ print }
' "$MBOX1_SVG" > "${MBOX1_SVG}.tmp" && mv "${MBOX1_SVG}.tmp" "$MBOX1_SVG"
echo "🔁 Replacing fill color with $new_color"
cairosvg "$MBOX1_SVG" -o "$BOX1_PNG"
echo "✅ PNG saved to $BOX1_PNG"

# Copy original SVG5 ==============================================
cp "$BOX5_SVG" "$MBOX5_SVG"
awk -v color1="$color" -v color2="$color2" -v color4="$color4" '
{
    gsub(/#29284a/, color1)
    gsub(/#7c78a3/, color2)
    gsub(/#6765ab/, color4)
    print
}
' "$MBOX5_SVG" > "${MBOX5_SVG}.tmp" && mv "${MBOX5_SVG}.tmp" "$MBOX5_SVG"
echo "🔁 Replacing fill color with $new_color"
cairosvg "$MBOX5_SVG" -o "$BOX5_PNG"
echo "✅ PNG saved to $BOX5_PNG"



