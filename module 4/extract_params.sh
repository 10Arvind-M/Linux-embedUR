#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 input.txt"
    exit 1
fi

input_file="$1"
output_file="output.txt"

> "$output_file"

while IFS= read -r line
do
    case "$line" in
        *\"frame.time\"*)
            echo "$line" >> "$output_file"
            ;;
        *\"wlan.fc.type\"*)
            echo "$line" >> "$output_file"
            ;;
        *\"wlan.fc.subtype\"*)
            echo "$line" >> "$output_file"
            ;;
    esac
done < "$input_file"

echo "Extraction complete. Check $output_file"

