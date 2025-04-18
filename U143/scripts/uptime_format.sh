#!/bin/bash

# Get current time
hour=$(date +%H)
min=$(date +%M)

# Get uptime days using awk
days=$(uptime | awk -F'( up |,)' '{ 
    for (i=1; i<=NF; i++) {
        if ($i ~ / day/ || $i ~ / days/) {
            split($i, a, " ")
            print a[1]
            exit
        }
    }
}')

# If no days found, set to 0
days=${days:-0}

# Output formatted uptime
echo "${hour}h ${min}m ${days}d"
