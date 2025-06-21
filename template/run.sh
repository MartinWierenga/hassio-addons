#!/usr/bin/env bash
echo "Starting add-on..."
python3 /run.py
if [ $? -ne 0 ]; then
    echo "Add-on failed to start."
    exit 1
else
    echo "Add-on started successfully."
fi