#!/usr/bin/env bash

DIRECTION="$1"

# Get the currently focused workspace
CURRENT_WS=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name')

# Get the currently focused output
CURRENT_OUTPUT=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).output')

# Get output positions
readarray -t OUTPUTS < <(i3-msg -t get_outputs | jq -r '.[] | select(.active==true) | "\(.name) \(.rect.x) \(.rect.y)"')

# Find the output in the requested direction
TARGET_OUTPUT=""
CURRENT_X=0
CURRENT_Y=0

for entry in "${OUTPUTS[@]}"; do
    read name x y <<< "$entry"
    if [[ "$name" == "$CURRENT_OUTPUT" ]]; then
        CURRENT_X=$x
        CURRENT_Y=$y
        break
    fi
done

BEST_DIST=1000000

for entry in "${OUTPUTS[@]}"; do
    read name x y <<< "$entry"
    case "$DIRECTION" in
        left)
            if (( x < CURRENT_X )); then
                DIST=$((CURRENT_X - x))
                if (( DIST < BEST_DIST )); then
                    BEST_DIST=$DIST
                    TARGET_OUTPUT=$name
                fi
            fi
            ;;
        right)
            if (( x > CURRENT_X )); then
                DIST=$((x - CURRENT_X))
                if (( DIST < BEST_DIST )); then
                    BEST_DIST=$DIST
                    TARGET_OUTPUT=$name
                fi
            fi
            ;;
        up)
            if (( y < CURRENT_Y )); then
                DIST=$((CURRENT_Y - y))
                if (( DIST < BEST_DIST )); then
                    BEST_DIST=$DIST
                    TARGET_OUTPUT=$name
                fi
            fi
            ;;
        down)
            if (( y > CURRENT_Y )); then
                DIST=$((y - CURRENT_Y))
                if (( DIST < BEST_DIST )); then
                    BEST_DIST=$DIST
                    TARGET_OUTPUT=$name
                fi
            fi
            ;;
    esac
done

# Move workspace if target found
if [[ -n "$TARGET_OUTPUT" ]]; then
    i3-msg "move workspace to output $TARGET_OUTPUT"
else
    echo "No output found in direction '$DIRECTION'"
fi
