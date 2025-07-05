#!/bin/bash

########################
#  USER CONFIGURATION  #
########################

LOGFILE="/var/log/ASL3-smart-announce.log"
NODE=64393

# List of active WAV base names (no ".wav", relative to /var/lib/asterisk/sounds/custom)
WAV_FILES=(
    "ID"
    "ID2"
    "cowboy"
    "jessica"
)

SLEEP_SECS=900
LAST_MINUTE_PLAYED=""

########################
#     MAIN  LOOP       #
########################

while true; do
    CURRENT_MINUTE=$(date +"%M")

    if [ "$CURRENT_MINUTE" != "$LAST_MINUTE_PLAYED" ]; then
        ACTIVE=$(asterisk -rx "core show channels concise" | grep -c '\bRPT')

        if [ "$ACTIVE" -eq 0 ]; then
            # Pick a random index from the WAV_FILES array
            COUNT=${#WAV_FILES[@]}
            INDEX=$((RANDOM % COUNT))
            WAV_PICK="${WAV_FILES[$INDEX]}"

            echo "$(date '+%F %T') Node $NODE idle — playing $WAV_PICK" | tee -a "$LOGFILE"
            asterisk -rx "rpt localplay $NODE /var/lib/asterisk/sounds/en/custom/$WAV_PICK"
        else
            echo "$(date '+%F %T') Node $NODE busy — skipping" | tee -a "$LOGFILE"
        fi

        # Prevent repeat this hour
        LAST_MINUTE_PLAYED="$CURRENT_MINUTE"
    fi

    sleep "$SLEEP_SECS"
done
