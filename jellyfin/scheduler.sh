#!/bin/bash
# This script uses a while loop to run another script every hour.

# Path to the script you want to run
SCRIPT_TO_RUN="./sync-media.sh"

# Infinite loop
while true
do
    # Run the script
    bash "$SCRIPT_TO_RUN"

    # Sleep for an hour (3600 seconds)
    echo ""
    echo "INFO | $(date +"%Y-%m-%d %H:%M:%S") | next sync is scheduled in an hour"
    echo "##############################################################"
    sleep 3600
done