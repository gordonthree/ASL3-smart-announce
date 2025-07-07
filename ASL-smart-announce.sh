#!/bin/bash

NODE=64549
WAVFILE=/var/lib/asterisk/sounds/triathlon2025  # No .wav extension for rpt localplay
CHECK_INTERVAL=60                                # seconds between idle checks
SLEEP_BETWEEN_PLAYS=$((60 * 60))                 # 1 hour between plays

# Allowed play window: 7:30 AM to 7:30 PM
START_HOUR=7
START_MINUTE=30
END_HOUR=19
END_MINUTE=30

while true; do
  # Get current time in minutes since midnight
  CURRENT_MINUTES=$(date +%H:%M | awk -F: '{ print ($1 * 60) + $2 }')
  START_MINUTES=$((START_HOUR * 60 + START_MINUTE))
  END_MINUTES=$((END_HOUR * 60 + END_MINUTE))

  if (( CURRENT_MINUTES >= START_MINUTES && CURRENT_MINUTES <= END_MINUTES )); then
    echo "$(date): Within allowed play window."

    # Wait until the repeater is not RX keyed
    while true; do
      RXKEYED=$(asterisk -rx "rpt show variables $NODE" | grep RPT_RXKEYED | awk -F= '{print $2}' | tr -d '\r')
      RXKEYED=${RXKEYED:-1}  # default to 1 (busy) if parsing fails

      if [ "$RXKEYED" -eq "0" ]; then
        echo "$(date): Node $NODE is idle (RX not keyed). Playing announcement."
        asterisk -rx "rpt localplay $NODE $WAVFILE"
        echo "$(date): Announcement played. Sleeping 1 hour."
        sleep $SLEEP_BETWEEN_PLAYS
        break  # exit wait loop and check time again
      else
        echo "$(date): Node $NODE busy (RX keyed). Checking again in $CHECK_INTERVAL seconds."
        sleep $CHECK_INTERVAL
      fi
    done
  else
    echo "$(date): Outside 7:30AM–7:30PM window. Sleeping $CHECK_INTERVAL seconds."
    sleep $CHECK_INTERVAL
  fi
done
