#!/bin/bash
#
# Author:   Peter Keel <seegras@discordia.ch>
# Date:     2023-03-24
# Version:  0.1
# License:  Public Domain
# URL:      https://seegras.discordia.ch/Programs/
# 
# Will output PDF files which have an owner password set
#
if ! command -v qpdf >/dev/null 2>&1; then
    echo >&2 "qpdf is required"
    exit 1
fi

shopt -s extglob
if ! ls *.pdf >/dev/null 2>&1 ; then 
    echo >&2 "No pdf files present"
    exit 1
fi

for PDFFILE in *.pdf; do 
if [[ -e "${PDFFILE}" ]]; then
qpdf --show-encryption  "${PDFFILE}" | awk -v s="password" '$0~s{r=1} 1; END{exit(r)}' >  /dev/null
RETVAL=$?
    if [ $RETVAL != 0 ]; then
    echo "${PDFFILE}"
    fi
fi
done
