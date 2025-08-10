#!/bin/bash
set -euo pipefail

# --- USER CONFIG -------------------------------------------------
NODE=45524
WAVFILE="/var/lib/asterisk/sounds/Nextel"  # no .wav
CHECK_INTERVAL=60          # seconds between RX checks
#SLEEP_BETWEEN_PLAYS=$((60*60))  # 1 h pause after each play

#RXKEYED=$(/usr/sbin/asterisk -rx "rpt show variables $NODE" | /usr/bin/awk -F= '/RPT_RXKEYED/{print $2}' | tr -d '\r')
#echo $RXKEYED
#exit



# Allowed window (local time): 07:30 → 19:30
#START_HOUR=7
#START_MINUTE=30
#END_HOUR=19
#END_MINUTE=30
# -----------------------------------------------------------------

#start_minutes=$((START_HOUR * 60 + START_MINUTE))
#end_minutes=$((END_HOUR   * 60 + END_MINUTE))

#log() { echo "$(date '+%Y-%m-%d %H:%M:%S')  $*"; }

#in_window() {
#  local now
#  now=$(date +%H:%M)
#  local mins=$((10#${now%:*} * 60 + 10#${now#*:}))
#  (( mins >= start_minutes && mins <= end_minutes ))
#}

  if true; then
    log "Within play window."

    # Wait until node is idle
    while :; do
      RXKEYED=$(/usr/sbin/asterisk -rx "rpt show variables $NODE" | /usr/bin/awk -F= '/RPT_RXKEYED/{print $2}' | tr -d '\r')
      RXKEYED=${RXKEYED:-1}

      if [[ "$RXKEYED" == 0 ]]; then
        log "Node $NODE idle. Playing $WAVFILE."
        /usr/sbin/asterisk -rx "rpt playback $NODE \"$WAVFILE\""
        log "Playback done. Sleeping $((SLEEP_BETWEEN_PLAYS/60)) min."
        # sleep "$SLEEP_BETWEEN_PLAYS"
        # bail out
        exit
        break   # go back to outer loop to re‑check time window
      fi

      log "Node busy (RXKEYED=1). Rechecking in ${CHECK_INTERVAL}s."
      sleep "$CHECK_INTERVAL"
    done
#  else
#    log "Outside 07:30–19:30 window. Sleeping ${CHECK_INTERVAL}s."
#    sleep "$CHECK_INTERVAL"
  fi