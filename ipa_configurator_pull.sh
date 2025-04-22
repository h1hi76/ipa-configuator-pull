#!/bin/bash

# Get the current user's username
USER_NAME=$(whoami)

# Base directory to search for the K36 folder
BASE_DIR="/Users/$USER_NAME/Library/Group Containers"

# Find the K36 folder dynamically
K36_DIR=$(find "$BASE_DIR" -maxdepth 1 -type d -name "K36*.apple.configurator" 2>/dev/null | head -n 1)

if [ -z "$K36_DIR" ]; then
    echo "Error: Could not find K36*apple.configurator directory."
    exit 1
fi

# Find the Assets directory
ASSETS_DIR="$K36_DIR/Library/Caches/Assets/TemporaryItems/MobileApps"

if [ ! -d "$ASSETS_DIR" ]; then
    echo "Error: Assets directory not found at $ASSETS_DIR"
    exit 1
fi

# Source directory to monitor
SOURCE_DIR="$ASSETS_DIR"

# Destination directory (Desktop)
DEST_DIR="/Users/$USER_NAME/Desktop"

# Create log file on desktop
LOG_FILE="$DEST_DIR/ipa_copy_log.txt"
touch "$LOG_FILE"

echo "Starting IPA file monitor script at $(date)" | tee -a "$LOG_FILE"
echo "Using dynamically found directory:" | tee -a "$LOG_FILE"
echo "Monitoring for IPA files in: $SOURCE_DIR" | tee -a "$LOG_FILE"
echo "Files will be copied to: $DEST_DIR" | tee -a "$LOG_FILE"
echo "Checking every 0.1 seconds" | tee -a "$LOG_FILE"
echo "----------------------------------------" | tee -a "$LOG_FILE"

# Function to find and copy IPA files
find_and_copy_ipa() {
    # Find IPA files up to 3 levels deep
    find "$SOURCE_DIR" -type f -name "*.ipa" -maxdepth 4 2>/dev/null | while read file; do
        filename=$(basename "$file")
        destination="$DEST_DIR/$filename"
        
        # Check if file already exists on desktop
        if [ ! -f "$destination" ]; then
            # Copy the file to desktop
            cp "$file" "$DEST_DIR/"
            echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Copied: $filename" | tee -a "$LOG_FILE"
        fi
    done
}

# Main loop - run continuously
while true; do
    find_and_copy_ipa
    sleep 0.1  # Check every 0.1 seconds
done