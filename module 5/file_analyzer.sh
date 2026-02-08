#!/bin/bash

log_file="errors.log"

show_help() {
cat << EOF
Usage: $0 [-d directory] [-k keyword] [-f file] [--help]

Options:
  -d directory   Directory to search recursively
  -k keyword     Keyword to search
  -f file        File to search directly
  --help         Display this help menu
EOF
exit 0
}

log_error() {
echo "$1" >> "$log_file"
echo "$1"
}

search_file() {
local file="$1"
local keyword="$2"
while IFS= read -r line; do
[[ "$line" =~ $keyword ]] && echo "$file:$line"
done <<< "$(cat "$file")"
}

search_dir() {
local dir="$1"
local keyword="$2"
for item in "$dir"/*; do
if [ -d "$item" ]; then
search_dir "$item" "$keyword"
elif [ -f "$item" ]; then
search_file "$item" "$keyword"
fi
done
}

if [ $# -eq 0 ]; then
log_error "No arguments provided"
exit 1
fi

while getopts ":d:k:f:-:" opt; do
case "$opt" in
d) directory="$OPTARG" ;;
k) keyword="$OPTARG" ;;
f) file="$OPTARG" ;;
-) case "$OPTARG" in
help) show_help ;;
*) log_error "Invalid option --$OPTARG"; exit 1 ;;
esac ;;
\?) log_error "Invalid option -$OPTARG"; exit 1 ;;
:) log_error "Option -$OPTARG requires an argument"; exit 1 ;;
esac
done

if [ -z "$keyword" ]; then
log_error "Keyword is missing"
exit 1
fi

if ! [[ "$keyword" =~ ^[a-zA-Z0-9._-]+$ ]]; then
log_error "Invalid keyword format"
exit 1
fi

if [ -n "$file" ]; then
if [ ! -f "$file" ]; then
log_error "File does not exist: $file"
exit 1
fi
search_file "$file" "$keyword"
elif [ -n "$directory" ]; then
if [ ! -d "$directory" ]; then
log_error "Directory does not exist: $directory"
exit 1
fi
search_dir "$directory" "$keyword"
else
log_error "Provide either -d directory or -f file"
exit 1
fi

exit 0

