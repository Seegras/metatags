#!/usr/bin/perl
#
# exif-info -- filter for (mostly pdf, but also djvu) documents which 
#	       prints out metadata and for pdf also the output of 
# 	       pdftotext. Great for use with Midnight Commander: 
# 	       View=%view{ascii} exif-info %f - 2> /dev/null
#
# Author:  Peter Keel <seegras@discordia.ch>
# Date:    26.11.2013
# Revised: 01.03.2014
# Version: 0.2
# License: Artistic License 2.0 or MIT License
# URL:     http://seegras.discordia.ch/Programs/
#

use Image::ExifTool qw(:Public);
use open qw/:std :utf8/;

die "Usage: exif-info filename\n"       unless($ARGV[0]);
$file = $ARGV[0];

my @ioTagList = ("Title", "Author", "Keywords", "ISBN", "EBX_PUBLISHER", "Publisher", "Subject", "CreateDate", "FileSize", "PageCount");
$info = ImageInfo($file, \@ioTagList);

# Suppresses superfluous Title(1) and enables me to format the output
if ($info->{'Title'} ne '') {
    print "Title    : $info->{'Title'}\n";
}
if ($info->{'Author'} ne '') {
    print "Author   : $info->{'Author'}\n";
}
if ($info->{'Keyword'} ne '') {
    print "Keywords : $info->{'Keywords'}\n";
}
if ($info->{'ISBN'} ne '') {
    print "ISBN     : $info->{'ISBN'}\n";
}
if ($info->{'EBX_PUBLISHER'} ne '') {
    print "Publisher: $info->{'EBX_PUBLISHER'}\n";
}
if ($info->{'Publisher'} ne '') {
    print "Publisher: $info->{'Publisher'}\n";
}
if ($info->{'Subject'} ne '') {
    print "Publisher: $info->{'Subject'}\n";
}
# tried parsing it first, was overkill.
$pubdate = $info->{'CreateDate'};
$pubdate =~ s/([0-9].):.*/$1/;
if ($pubdate ne '') {
    print "Date     : $pubdate\n";
}
if ($info->{'FileSize'} ne '') {
    print "Size     : $info->{'FileSize'}\n";
}
if ($info->{'PageCount'} ne '') {
    print "Pages    : $info->{'PageCount'}\n";
}
print "\n";

# I also tried CAM::PDF and Text::Autoformat, and they were slow.
open PDF, "/usr/bin/pdftotext -raw -nopgbrk -q \"$file\" - 2>/dev/null | fmt -s |"
	or die "error opening pdf \"$file\"\n";
while (<PDF>) {
    print $_;
}
close PDF;
