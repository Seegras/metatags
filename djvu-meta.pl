#!/usr/bin/perl
# 
# djvu-meta -- generates meta-files for djvu
# 
# Author:  Peter Keel <seegras@discordia.ch>
# Date:    2014-03-01
# Revised: 2020-05-06
# Version: 0.2
# License: Artistic License 2.0 or MIT License
# URL:     http://seegras.discordia.ch/Programs/
# 
#
use strict;
use Getopt::Long;
use Pod::Usage;
use Image::ExifTool qw(:Public);
use open qw/:std :utf8/;

my $dname;
my $needshelp;
my $createmeta;
my $debug;
my $fixtitle;
my $prefix;
my @dir_contents;

&Getopt::Long::Configure( 'pass_through', 'no_autoabbrev');
&Getopt::Long::GetOptions(
    'help|h'            => \$needshelp,
    'meta|m'            => \$createmeta,
    'prefix|p=s'        => \$prefix,
    'debug|d'           => \$debug,
    'fix|f'             => \$fixtitle,
);

if (!$ARGV[0]) {
    $dname = ".";
} else { 
    $dname=$ARGV[0]; 
}

if ($needshelp) {
    pod2usage(1);
}

opendir(my $in_dir, $dname) || die "I am unable to access that directory...Sorry";
@dir_contents = readdir($in_dir);
closedir($in_dir);

@dir_contents = sort(@dir_contents);
    foreach my $filename (@dir_contents) {
    (my $name, my $suffix) = $filename =~ /^(.*)(\.[^.]*)$/;
        if ($filename ne ".." and $filename ne "." and $suffix eq ".djvu") {
            my $oldtitle = '';
            my $title = '';
            my $pubdate = '';
            my $publisher = '';
            my $author = '';
            my $isbn = '';
            my $info;

            my @ioTagList = ("Title", "Author", "Keywords", "ISBN", "EBX_PUBLISHER", "Publisher", "Subject", "CreateDate", "FileSize", "PageCount");
            $info = ImageInfo($filename, \@ioTagList);

            if ($info->{'Title'} ne '') {
                $oldtitle = $info->{'Title'};
                if ($debug) { print "$oldtitle\n"}
            }
            if ($info->{'CreateDate'} ne '') {
                $pubdate = $info->{'CreateDate'};
                $pubdate =~ s/([0-9].):.*/$1/;
                if ($debug) { print "$pubdate\n"}
            }
            if ($info->{'Author'} ne '') {
                $author = $info->{'Author'};
                if ($debug) { print "$author\n"}
            }        
            if ($info->{'Publisher'} ne '') {
                $publisher = $info->{'Publisher'};
                if ($debug) { print "$publisher\n"}
            }
            if ($info->{'ISBN'} ne '') {
                $isbn = $info->{'ISBN'};
                if ($debug) { print "$isbn\n"}
            }

            if ($fixtitle) {
                $title = $oldtitle;   # title, gets sanitized
            } else {
                $title = $name;   # title, gets sanitized
            }
            $title =~ s/([A-Z-])/_$1/g;
            $title =~ s/([0-9]+)/_$1/g;
            $title =~ s/_/ /g; # replace underscores with spaces
            $title =~ s/  / /g; # no double spaces
            $title =~ s/^-//g; # never start with a dash
            $title =~ s/^ //g; # don't start with a space
            $title =~ s/S ([0-9]+) - E ([0-9]+)/S$1E$2/g; # fix series
            $title =~ s/S ([0-9]+) E ([0-9]+)/S$1E$2/g; # fix series
            if ($oldtitle eq "") { 
                $oldtitle = $title;
                if ($debug) { print "$title\n"}
            } 
            if ($prefix) {
                $oldtitle = $prefix . $oldtitle;
            } 
            if ($fixtitle) { 
                if ($oldtitle ne $title) {
                    $oldtitle = $title;
                    if ($debug) { print "$title\n"}
                }
            } 
            if ($createmeta) {
                open (my $divu_meta,">:encoding(UTF-8)", "$dname/$name.meta");
                binmode($divu_meta, ":encoding(UTF-8)");
                if ($title ne "") {
                    print $divu_meta "title\t\"$oldtitle\"\n";
                }
                if ($pubdate ne "") {
                    print $divu_meta "year\t\"$pubdate\"\n";
                }
                if ($publisher ne "") {
                    print $divu_meta "publisher\t\"$publisher\"\n";
                }
                if ($author ne "") {
                    print $divu_meta "author\t\"$author\"\n";
                }
                if ($isbn ne "") {
                    print $divu_meta "ISBN\t\"$isbn\"\n";
                }
                close ($divu_meta); 
            }
        #binmode STDOUT, ":utf8"; 
        system ("export LC_CTYPE=en_GB.UTF-8; /usr/bin/djvused -u -e \"create-shared-ant\; set-meta \\\"$name.meta\\\"\" -s \"$dname/$filename\"\n");
        }
    }

__END__

=head1 NAME

djvu-meta -- sets djvu metadata from titles or from matadata-files, can
             also generate metadata-files. needs djvused. 

=head1 SYNOPSIS

B<This program> [options] [directory ...]

 Options:
   -h|--help
   -d|--debug
   -p|--prefix
   -m|--meta
   -f|--fix

=head1 OPTIONS

=over 8

=item B<-h|--help>

Print a brief help message and exit.

=item B<-d|--debug>

Prints out debug output.

=item B<-f|--fix>

Fix title. Takes the title from the matadata and tries to sanitize it.

=item B<-m|--meta>

Creates a metdata-file, either from title, or from already existing 
metadata within the file. Writes this metadata to the file. 

=item B<-p|--prefix>

Prefixes the movie title with a string of your choosing. Useful for
series that have the series-name not in the filename. 

=back

=head1 DESCRIPTION

B<This program> Sets the metadata of djvu files within the current 
directory. It sets them from a file named the same as the djvu-file,
but with the suffix .meta instead. It can also generate these meta-
files.

=cut
