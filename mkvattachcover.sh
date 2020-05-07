#!/bin/sh
# 
# mkvattachcover -- attach cover and fanart images downloaded with
#                   MediaElch to mkv files.
#
# Author:  Peter Keel <seegras@discordia.ch>
# License: MIT License
#
if ! command -v convert mkvpropedit >/dev/null 2>&1; then
    echo >&2 "convert and mkvpropedit are required"
    exit 1
fi

for filename in ./*.mkv; do 
filename_no_ext=$(basename "$filename" .mkv);
if [ -e "$filename_no_ext-poster.jpg" ]; then
    convert -scale 600x\> "$filename_no_ext-poster.jpg" \
        "$filename_no_ext-poster2.jpg"
    convert -scale 120x\> "$filename_no_ext-poster.jpg" \
        "$filename_no_ext-poster3.jpg"
    mkvpropedit --attachment-name cover.jpg "$filename" \
        --add-attachment "$filename_no_ext-poster2.jpg"
    mkvpropedit --attachment-name small_cover.jpg "$filename" \
        --add-attachment "$filename_no_ext-poster3.jpg"
    rm "$filename_no_ext-poster2.jpg" "$filename_no_ext-poster3.jpg"
fi
if [ -e "$filename_no_ext-fanart.jpg" ]; then
    convert -scale x600\> "$filename_no_ext-fanart.jpg" \
        "$filename_no_ext-fanart2.jpg"
    convert -scale x120\> "$filename_no_ext-fanart.jpg" \
        "$filename_no_ext-fanart3.jpg"
    mkvpropedit --attachment-name cover_land.jpg "$filename" \
        --add-attachment "$filename_no_ext-fanart2.jpg"
    mkvpropedit --attachment-name small_cover_land.jpg "$filename" \
        --add-attachment "$filename_no_ext-fanart3.jpg"
    rm "$filename_no_ext-fanart2.jpg" "$filename_no_ext-fanart3.jpg"
elif [ -e "$filename_no_ext-thumb.jpg" ]
then
    convert -scale x600\> "$filename_no_ext-thumb.jpg" \
        "$filename_no_ext-fanart2.jpg"
    convert -scale x120\> "$filename_no_ext-thumb.jpg" \
        "$filename_no_ext-fanart3.jpg"
    mkvpropedit --attachment-name cover_land.jpg "$filename" \
        --add-attachment "$filename_no_ext-fanart2.jpg"
    mkvpropedit --attachment-name small_cover_land.jpg "$filename" \
        --add-attachment "$filename_no_ext-fanart3.jpg"
    rm "$filename_no_ext-fanart2.jpg" "$filename_no_ext-fanart3.jpg" "$filename_no_ext-thumb.jpg"
fi
done
