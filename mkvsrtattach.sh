#!/bin/bash
#
# mkvsrtattach -- attach srt to an mkv file of similar name.
# 
# Does only work with one sub per movie right now, uses bash 4.x
#
# Author:  Peter Keel <seegras@discordia.ch>
# License: MIT License
#
if ! command -v mkvmerge >/dev/null 2>&1; then
    echo >&2 "mkmerge is required"
    exit 1
fi

debug=1
for filename in *.srt; do 
    filename_no_ext=$(basename "$filename" .srt)
    # easy case, just attach the subtitle
    if [ -e "$filename_no_ext.mkv" ]
    then
	mkvmerge -o $filename_no_ext.OUT.mkv $filename_no_ext.mkv --language 0:eng $filename
	    mv ${filename_no_ext}.OUT.mkv ${filename_no_ext}.mkv
	    rm $filename
    fi
    IFS='-' read -ra fields <<< "$filename_no_ext"
    if [ $debug ]; then set | grep ^fields=\\\|^var=; fi
    fnum=$((${#fields[@]}-1))
    if [ $debug ]; then echo $fnum; fi
    # in this case, the ending is probably a language code
    if [ ${#fields[$fnum]} -eq 3 ]
    then
	mkvfields=$[fnum-1]
	i=1
	base=${fields[0]}
	while [ $i -lt $mkvfields ]
	do
	    base+="-"
	    base+=${fields[$i]}
	    i=$[$i+1]
	done
	if [ $debug ]; then echo $base; fi
	langcode=${fields[$fnum]}
	declare -l langcode
	if [ $debug ]; then echo $langcode; fi
	# we now hopefully have the filename 
        if [ -e "$base.mkv" ]
	then
	    mkvmerge -o ${base}.OUT.mkv ${base}.mkv --language 0:$langcode $filename
	    mv ${base}.OUT.mkv ${base}.mkv
	    rm $filename
	fi
    fi

done
