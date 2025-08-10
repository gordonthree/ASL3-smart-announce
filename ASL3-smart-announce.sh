#!/bin/bash
set -euo pipefail

# --- USER CONFIG -------------------------------------------------
NODE=45524
WAVFILE="/var/lib/asterisk/sounds/Nextel"  # no .wav
CHECK_INTERVAL=60          # seconds between RX checks

    # Wait until node is idle
    while :; do
      RXKEYED=$(/usr/sbin/asterisk -rx "rpt show variables $NODE" | /usr/bin/awk -F= '/RPT_RXKEYED/{print $2}' | tr -d '\r')
      RXKEYED=${RXKEYED:-1}

      if [[ "$RXKEYED" == 0 ]]; then
        #log "Node $NODE idle. Playing $WAVFILE."
        /usr/sbin/asterisk -rx "rpt playback $NODE \"$WAVFILE\""
        #log "Playback done. Sleeping $((SLEEP_BETWEEN_PLAYS/60)) min."
        # sleep "$SLEEP_BETWEEN_PLAYS"
        # bail out
        exit
        break   # go back to outer loop to re‑check time window
      fi

      # "Node busy (RXKEYED=1). Rechecking in ${CHECK_INTERVAL}s."
      sleep "$CHECK_INTERVAL"
    done
