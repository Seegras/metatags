#!/usr/bin/perl
# 
# exif-rename -- renames various files according to their exif/xmp metatags
#
# Author:  Peter Keel <seegras@discordia.ch>
# Date:    11.04.2011
# Revised: 26.11.2013
# Version: 0.3
# License: Artistic License 2.0 or MIT License
# URL:     http://seegras.discordia.ch/Programs/
# 

use Getopt::Long;
use Pod::Usage;
use File::Copy;
use Image::ExifTool qw(:Public);
use File::Basename;
use Term::ANSIColor;
use File::Copy;

# Config Options

&Getopt::Long::Configure( 'pass_through', 'no_autoabbrev');
&Getopt::Long::GetOptions(
		'help|h'		=> \$needshelp,
		'rename|r'		=> \$rename,
		'move|m'		=> \$move,
);

if (!$ARGV[0]) {
    $needshelp=1;
}

if ($needshelp) {
    pod2usage(1);
}

if ($move) {
    if  (-f "wouldberenamed") {
	exit; 
    }
    if  (! -d "wouldberenamed") {
	mkdir ("wouldberenamed");
    }
}

foreach $file (@ARGV) {

    $_ = $file; 
    ($name,$suffix) = $file =~ /^(.*)(\.[^.]*)$/;
    my $exifTool = new Image::ExifTool;
    my $info = $exifTool->ImageInfo($file);

    if ($$info{'Artist'}) {
        # print "$$info{'Artist'}\n"; 
	$artist = $$info{'Artist'};
    } elsif ($$info{'Author'}) {
        # print "$$info{'Author'}\n"; 
	$artist = $$info{'Author'};
    } else {
	$artist = "unknown";
    }
    if ($$info{'Title'}) {
        # print "$$info{'Title'}\n"; 
	$title = $$info{'Title'};
    } elsif ($$info{'Book Title'}) {
	$title = $$info{'Book Title'};
    } else {
	$title = "unknown";
    }
$title =~ s/\//-/g; 
$newfile = $artist . " - " . $title . $suffix;

# FIXME: code deciding new name stupid

    if ($newfile ne $file) {
        # $exname = $newfile;
        # $exname =~ s/\.$suffix//;
        ($exname,$suffix) = $newfile =~ /^(.*)(\.[^.]*)$/;
    	while (-e "$newfile") {    
            print ("WARN \"$newfile\" exists\n");
            $counter++;
	    $newfile = $exname . "-" . $counter . $suffix;
	}
    }

    if ($rename) {
        rename ("$file", "$newfile") unless ($newfile eq $file);
        print ("renamed $file to \"$newfile\"\n") unless ($newfile eq $file);
    } elsif ($newfile ne $file) {
	print color 'bold blue';
	print ("would rename: ");
	print color 'reset';
	print ("$file\n");
	print color 'bold blue';
	print (" ->           ");
	print color 'reset';
	print ("$newfile\n");
    }
    if ($move) {
	move("$file", "wouldberenamed/$file") unless ($newfile eq $file);
    }
}

__END__

=head1 NAME

exif-rename - read exif information from file and renames it 
accordingly. It should work with anything providing exif-tags, 
tested with PDF, DJVU, M4V, OGM, MKV and MP3

=head1 SYNOPSIS

B<This program> [options] [files ...]

 Options:
   -h|--help
   -r|--rename
   -m|--move 

=head1 OPTIONS

=over 8

=item B<-h|--help>

Print a brief help message and exit.

=item B<-r|--rename>

Really rename all the files. Without this, it only prints out what it 
would do. 

=item B<-m|--move>

Move files that would be renamed to a folder named "wouldberenamed".

=back

=head1 DESCRIPTION

B<This program> does something

=cut
