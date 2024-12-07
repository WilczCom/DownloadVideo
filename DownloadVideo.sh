#!/bin/bash

# Usage: DownloadVideo.sh "https://example-url-with-{no}-of-video"

delete_temp=true

echo ""

while getopts ":t" opt; do
    case $opt in
        t)
            delete_temp=false
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            echo "Usage: $0 [-t] <URL format>"
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

if [ $# -ne 1 ]; then
    echo "Usage: $0 [-c] <URL format>"
    exit 1
fi

url_format=$1

# download video parts


mkdir temp-files
cd temp-files

i=1
while true; do
    curl -f -s -o "temp-file-$i.ts" "${url_format/\{no\}/$i}"
    if [ $? -ne 0 ]; then
        echo -ne "Download complete! \r"
        rm "temp-file-$i.ts" 2>/dev/null  # Remove the file if it was created
        break  # Exit the loop if download fails
    else
        echo -ne "Downloading file: $i\r"
    fi
    # Increment i (you'll replace this with your logic)
    i=$((i + 1))
done

cd ..

# make video from parts

new_name="video.ts"

while true; do
    if [ -f "$new_name" ]; then
    	j=$((j + 1))
        new_name="video($j).ts"
    else
        break
    fi
done

# Count the total number of files in the directory

total_files=$(ls -1 temp-files/temp-file-*.ts 2>/dev/null | wc -l)

completed=0

for ((i = 1; i <= total_files; i++)); do
    if [ -f "temp-files/temp-file-$i.ts" ]; then
        cat "temp-files/temp-file-$i.ts" >> "$new_name"
        completed=$((complete + 1))
        percentage=$((complete * 100 / total_files))
        echo -ne "Progress: $percentage% \r" # -ne to overwrite the same line
    fi
done

echo -ne "Merging completed! \r"

if [ "$delete_temp" = true ]; then
    cd temp-files
    rm temp-file-*.ts 2>/dev/null
    cd ..
    rm -r temp-files
    echo -ne "Temp files deleted! \r"
fi

echo -ne "\r File $new_name is ready!"
echo ""
