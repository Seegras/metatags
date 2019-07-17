#!/usr/bin/perl
#
# type1rename -- Renames Type1-fonts (afm, pfm, pfb, pfa, inf) to their 
#                correct name according to their postscript meta-info. 
#
# Author:  Peter Keel <seegras@discordia.ch>
# Date:    20.11.2003
# Revised: 19.03.2012
# Version: 1.1
# License: Artistic License 2.0 or MIT License and GPLv2 
# URL:     https://seegras.discordia.ch/Programs/
#
#
# Usage: type1rename <directory>
# It takes the actual directory if no directory is specified
#

use Getopt::Long;
use Pod::Usage;

&Getopt::Long::Configure( 'pass_through', 'no_autoabbrev');
&Getopt::Long::GetOptions(
		'help|h'		=> \$needshelp,
);

if ($needshelp) {
pod2usage(1);
}

if ($ARGV[0] ne '') {
$dname = $ARGV[0];
} else {
$dname = ".";
}

#$OK_CHARS='-a-zA-Z0-9'; # with dashes
$OK_CHARS='a-zA-Z0-9';  # no dashes

opendir(IN_DIR, $dname) || die "I am unable to access that directory...Sorry";
@dir_contents = readdir(IN_DIR);
closedir(IN_DIR);

@dir_contents = sort(@dir_contents);
    foreach $x (@dir_contents) {
        if ($x =~ m/\.[Pp][Ff][Bb]/i) {
    		&pfb;
	}
        if ($x =~ m/\.[Pp][Ff][Aa]/i) {
    		&pfa;
	}
        if ($x =~ m/\.[Pp][Ff][Mm]/i) {
    		&pfm;
	}
        if ($x =~ m/\.[Ii][Nn][Ff]/i) {
    		&inf;
	}
        if ($x =~ m/\.[Aa][Ff][Mm]/i) {
    		&afm;
	}
    }

sub afm { 
$filename = $x;
open(IN_FILE,"<$dname/$filename") || die "Cannot open $filename for input\n";
while(<IN_FILE>){
    if ($_ =~ m/FullName/i) {
	chomp($_);
        $_ =~ s/.*FullName\ //i;
	$_ =~ s/[^$OK_CHARS]//go;
	rename("$dname/$filename","$dname/$_.afm") unless ("$filename" eq "$_.afm");

    }
}
close IN;
}

sub pfa { 
$filename = $x;
open(IN_FILE,"<$dname/$filename") || die "Cannot open $filename for input\n";
while(<IN_FILE>){
    if ($_ =~ m/FullName/i) {
	chomp($_);
        $_ =~ s/.*FullName\ \(([^\)]*)\).*/$1/i;
	$_ =~ s/[^$OK_CHARS]//go;
	rename("$dname/$filename","$dname/$_.pfa") unless ("$filename" eq "$_.pfa");
    }
}
close IN;
}

sub inf { 
$filename = $x;
open(IN_FILE,"<$dname/$filename") || die "Cannot open $filename for input\n";
while(<IN_FILE>){
    if ($_ =~ m/FullName/i) {
        $_ =~ s/.*FullName\ \(([^\)]*)\)/$1/i;
	chomp($_);
	$_ =~ s/[^$OK_CHARS]//go;
	rename("$dname/$filename","$dname/$_.inf") unless ("$filename" eq "$_.inf");
    }
}
close IN;
}

sub pfm { 
$filename = $x;
open(IN_FILE,"<$dname/$filename") || die "Cannot open $filename for input\n";
while(<IN_FILE>){
    if ($_ =~ m/PostScript\000/i) {
        $_ =~ s/.*PostScript\0([^\0]*)\0([^\0]*)\0.*/$2/g; 
	chomp($_);
	$_ =~ s/[^$OK_CHARS]//go;
	rename("$dname/$filename","$dname/$_.pfm") unless ("$filename" eq "$_.pfm");
    }
}
close IN;
}

sub pfb { 
$filename = $x;
open(IN_FILE,"<$dname/$filename") || die "Cannot open $filename for input\n";
while(<IN_FILE>){
    if ($_ =~ m/\/FullName/i) {
        $_ =~ s/.*?FullName.*?\(([^\)]*?)\).*/$1/s;
	$_ =~ s/[^$OK_CHARS]//go;
	rename("$dname/$filename","$dname/$_.pfb") unless ("$filename" eq "$_.pfb");
    }
}
close IN;
}

__END__

=head1 NAME

type1-rename - renames Type1-fonts according to their internal name.

=head1 SYNOPSIS

B<This program> [options] [directory ...]

 Options:
   -h|--help

=head1 OPTIONS

=over 8

=item B<-h|--help>

Print a brief help message and exit.

=back

=head1 DESCRIPTION

B<This program> Tries to rename type1-fonts according to their internal
names. It processes all type1-fonts of the 
directory you're in, unless given another directory. 

=cut
