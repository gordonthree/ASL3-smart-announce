#!/bin/bash

###########################################################
### https://github.com/GooseThings/ASL3-smart-announce/ ###
###     Code by Goose - N8GMZ - MIT License - 202%      ###
###########################################################

LOGFILE="/var/log/ASL3-smart-announce.log"
exec >> "$LOGFILE" 2>&1

NODE=12345 #put your node number here
WAVDIR=/var/lib/asterisk/sounds/en/custom/announcements  # Folder with .wav files
CHECK_INTERVAL=60                              # seconds between idle checks
SLEEP_BETWEEN_PLAYS=$((60 * 60))               # 1 hour between plays

# Allowed play window: 7:30 AM to 7:30 PM - change to whatever you want
START_HOUR=7
START_MINUTE=30
END_HOUR=19
END_MINUTE=30

while true; do
  CURRENT_MINUTES=$(date +%H:%M | awk -F: '{ print ($1 * 60) + $2 }')
  START_MINUTES=$((START_HOUR * 60 + START_MINUTE))
  END_MINUTES=$((END_HOUR * 60 + END_MINUTE))

  if (( CURRENT_MINUTES >= START_MINUTES && CURRENT_MINUTES <= END_MINUTES )); then
    echo "$(date): Within allowed play window."

    # Wait until repeater is not RX keyed
    while true; do
      RXKEYED=$(asterisk -rx "rpt show variables $NODE" | grep RPT_RXKEYED | awk -F= '{print $2}' | tr -d '\r')
      RXKEYED=${RXKEYED:-1}  # default to busy if variable missing

      if [ "$RXKEYED" -eq "0" ]; then
        # Pick a random WAV file from the directory
        WAVFILE=$(find "$WAVDIR" -type f -name '*.wav' | shuf -n 1)
        BASENAME=$(basename "$WAVFILE")

        echo "$(date): Node $NODE is idle. Playing random file: $BASENAME"
        asterisk -rx "rpt playback $NODE /var/lib/asterisk/sounds/en/custom/announcement/$BASENAME"       # For some reason ASL3 has problems without the full path
        echo "$(date): Playback done. Sleeping 1 hour."
        sleep $SLEEP_BETWEEN_PLAYS
        break
      else
        echo "$(date): Node $NODE busy. Rechecking in $CHECK_INTERVAL seconds."
        sleep $CHECK_INTERVAL
      fi
    done
  else
    echo "$(date): Outside 7:30AM–7:30PM window. Sleeping $CHECK_INTERVAL seconds."
    sleep $CHECK_INTERVAL
  fi
done
