#!/usr/bin/perl
# 
# Determines whether movie files are 2K, 1080p, 720p, DVD or less.
# 
# Author:  Peter Keel <seegras@discordia.ch>
# Date:    
# Revised: 2019-10-16
# Revised: 2022-09-20
# Version: 0.4
# License: Artistic License 2.0 or MIT License
# URL:     http://seegras.discordia.ch/Programs/
# 

use strict;
use Getopt::Long;
use Pod::Usage;

my $needshelp = 0;
my $file_name;
my $in_file;
my $only4k = 0;
my @files = ();


&Getopt::Long::Configure( 'pass_through', 'no_autoabbrev', 'bundling');
&Getopt::Long::GetOptions(
		'help|h'		=> \$needshelp,
		'4K|4'		=> \$only4k,
);

die "Usage: 720or1080 filename\n"       unless($ARGV[0]);
my $file = $ARGV[0];

if ($needshelp) {
pod2usage(1);
}

foreach my $file_name (@ARGV) {
    open(in_file, "mediainfo --inform=file://720or1080.csv $file_name|") || die "Cannot open $file_name for input\n";
    while(<in_file>){
	$_ =~ /(\S+) (\d+)x(\d+)/;
	$file=$1;
	my $width=$2;
	my $height=$3;
        #print "$width $height";
	if (($width > 1920) && ($height <= 2160)) {
	print ("2160p: ", $file, " ", $width, " ", $height, "\n");
	}
	if (($width > 1280) && ($width <= 1920) && ! $only4k) {
	print ("1080p: ", $file, " ", $width, " ", $height, "\n");
	}
	if (($width > 720) && ($width <= 1280) && ($height <= 720) && ! $only4k) {
	print (" 720p: ", $file, " ", $width, " ", $height, "\n");
	}
	if (($width <= 720) && ($height <= 576) && ($height >= 480) && ! $only4k) {
	print ("  DVD: ", $file, " ", $width, " ", $height, "\n");
	}
	if (($width < 720) && ($height < 480) && ! $only4k) {
	print ("  LOW: ", $file, " ", $width, " ", $height, "\n");
	}
    }
    close in_file;
}
