#!/usr/bin/perl
# 
# Determines whether movie files are 2K, 1080p, 720p, DVD or less.
# 
# Author:  Peter Keel <seegras@discordia.ch>
# Date:    
# Revised: 2019-10-16
# Version: 0.2
# License: Artistic License 2.0 or MIT License
# URL:     http://seegras.discordia.ch/Programs/
# 

use Getopt::Long;
use Pod::Usage;

$debug = 1;
@files = ();

&Getopt::Long::Configure( 'pass_through', 'no_autoabbrev', 'bundling');
&Getopt::Long::GetOptions(
		'help|h'		=> \$needshelp,
);

die "Usage: 720or1080 filename\n"       unless($ARGV[0]);
$file = $ARGV[0];

if ($needshelp) {
pod2usage(1);
}

foreach $file_name (@ARGV) {
    open(IN_FILE,"<$file_name") || die "Cannot open $file_name for input\n";
    while(<IN_FILE>){
	$_ =~ /(\S+) (\d+)x(\d+)/;
	$file=$1;
	$width=$2;
	$height=$3;
	if (($width > 1920) && ($height <= 2160)) {
	print ("2160p: ", $file, " ", $width, " ", $height, "\n");
	}
	if (($width > 1280) && ($width <= 1920)) {
	print ("1080p: ", $file, " ", $width, " ", $height, "\n");
	}
	if (($width > 720) && ($width <= 1280) && ($height <= 720)) {
	print (" 720p: ", $file, " ", $width, " ", $height, "\n");
	}
	if (($width <= 720) && ($height <= 576) && ($height >= 480)) {
	print ("  DVD: ", $file, " ", $width, " ", $height, "\n");
	}
	if (($width < 720) && ($height < 480)) {
	print ("  LOW: ", $file, " ", $width, " ", $height, "\n");
	}
    }
    close IN;
}
