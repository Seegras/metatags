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

DEBUG=1
for FILE in ./*.srt; do 
    filename_no_ext="$( basename "$FILE" .srt )"
    # easy case, just attach the subtitle
    if [ -e "$filename_no_ext.mkv" ]
    then
        mkvmerge -o "$filename_no_ext".OUT.mkv "$filename_no_ext".mkv --language 0:eng "${FILE}"
            mv "${filename_no_ext}".OUT.mkv "${filename_no_ext}".mkv
            rm "${FILE}"
    fi
    IFS='-' read -ra fields <<< "${filename_no_ext}"
    if [[ "${DEBUG}" ]]; then set | grep ^fields=\\\|^var=; fi
    fnum=$((${#fields[@]}-1))
    if [[ ${DEBUG} ]]; then echo ${fnum}; fi
    # in this case the ending is probably a language code
    if [[ ${fnum} -eq 2 ]] 
    then
        base="${fields[0]}"
    fi
    if [[ ${fnum} -eq 3 ]] 
    then
        base="${fields[0]}-${fields[1]}"
    fi
    if [[ ${fnum} -eq 4 ]]
    then
        base="${fields[0]}-${fields[1]}-${fields[2]}"
    fi
    #mkvfields=${fnum}
    #cnt=1
    #for ((cnt=1;cnt<$fnum;++cnt)) do
    #    base+="-"
    #    base+=${fields[$cnt]}
    #done
    if [[ ${DEBUG} ]]; then echo "${base}"; fi
    LANGCODE=${fields[$fnum]}
    declare -l LANGCODE
    if [ ${DEBUG} ]; then echo "${LANGCODE}"; fi
    # we now hopefully have the filename 
    if [ -e "$base.mkv" ]
    then
        mkvmerge -o "${base}".OUT.mkv "${base}".mkv --language 0:"${LANGCODE}" "${FILE}"
        mv "${base}".OUT.mkv "${base}".mkv
        rm "${FILE}"
    fi
done
