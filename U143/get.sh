#!/bin/bash

# File path
css_file="$HOME/.config/gtk-4.0/gtk.css"

# Extract hex code for background-color in .background block
# Use sed to grab the hex code from the specific pattern
hex_code=$(sed -n '/^\.background {$/{
    N
    s/^\.background {\n  background-color: \(#[0-9a-fA-F]\{6\}\);/\1/p
}' "$css_file")

# Output the result
if [ -n "$hex_code" ]; then
  echo $hex_code
else
  echo "Background color not found."
fi
