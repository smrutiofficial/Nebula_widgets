#!/bin/bash

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <hexcolor> <saturation> <value>"
  echo "Example: $0 \"#343343\" 16 100"
  exit 1
fi

hexcolor="$1"
sat="$2"
val="$3"

python3 - <<EOF
import colorsys

hexcolor = "$hexcolor".lstrip("#")
r, g, b = [int(hexcolor[i:i+2], 16)/255.0 for i in (0, 2, 4)]

# Convert RGB to HSV
h, s, v = colorsys.rgb_to_hsv(r, g, b)

# Override saturation and value (passed in as 0–100)
s = $sat / 100.0
v = $val / 100.0

# Convert back to RGB
r, g, b = colorsys.hsv_to_rgb(h, s, v)
r, g, b = [round(c * 255) for c in (r, g, b)]

# Output new hex color
print("#{:02X}{:02X}{:02X}".format(r, g, b))
EOF
