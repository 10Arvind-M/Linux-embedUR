#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <source_directory> <backup_directory> <file_extension>"
    exit 1
fi

SOURCE_DIR="$1"
BACKUP_DIR="$2"
EXTENSION="$3"


shopt -s nullglob
FILES=("$SOURCE_DIR"/*."$EXTENSION")


if [ ${#FILES[@]} -eq 0 ]; then
    echo "No .$EXTENSION files found in $SOURCE_DIR"
    exit 1
fi


if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR" || { echo "Failed to create backup directory"; exit 1; }
fi


export BACKUP_COUNT=0
TOTAL_SIZE=0

echo "Files to be backed up:"
for file in "${FILES[@]}"; do
    size=$(stat -c%s "$file")
    echo "$(basename "$file") - $size bytes"
done

for file in "${FILES[@]}"; do
    base=$(basename "$file")
    dest="$BACKUP_DIR/$base"

    if [ -f "$dest" ]; then
        if [ "$file" -nt "$dest" ]; then
            cp "$file" "$dest"
            ((BACKUP_COUNT++))
            size=$(stat -c%s "$file")
            ((TOTAL_SIZE+=size))
        fi
    else
        cp "$file" "$dest"
        ((BACKUP_COUNT++))
        size=$(stat -c%s "$file")
        ((TOTAL_SIZE+=size))
    fi
done

REPORT_FILE="$BACKUP_DIR/backup_report.log"

{
echo "Backup Summary Report"
echo "Total files backed up: $BACKUP_COUNT"
echo "Total size backed up: $TOTAL_SIZE bytes"
echo "Backup directory: $BACKUP_DIR"
echo "Date: $(date)"
} > "$REPORT_FILE"

echo "Backup completed. Report saved to $REPORT_FILE"
                                                     
