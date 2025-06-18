#!/usr/bin/env bash
echo "Starting Studio Code Server Checker add-on..."
python3 /monitor.py
if [ $? -ne 0 ]; then
    echo "Studio Code Server Checker add-on failed to start."
    exit 1
else
    echo "Studio Code Server Checker add-on started successfully."
fi