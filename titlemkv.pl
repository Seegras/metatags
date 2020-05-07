#!/usr/bin/perl
# 
# titlemkv -- puts metadata titles into mkv files and generates .nfo
#             for xmbc.
# 
# Author:  Peter Keel <seegras@discordia.ch>
# Date:    2013-09-13
# Revised: 2013-09-21
# Revised: 2020-05-06
# Version: 0.5
# License: Artistic License 2.0 or MIT License
# URL:     http://seegras.discordia.ch/Programs/
# 
# Caveats/assumed bugs: 
# - DATE_RELEASED could contain a year or a date; and depending on
#   that should be put into "year" or "aired" tag of .nfo files.
#
use strict;
use Getopt::Long;
use Pod::Usage;

my $dname;
my $needshelp;
my $createnfo;
my $prefix;
my $debug;
my $fixtitle;

&Getopt::Long::Configure( 'pass_through', 'no_autoabbrev');
&Getopt::Long::GetOptions(
    'help|h'            => \$needshelp,
    'nfo|n'             => \$createnfo,
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
my @dir_contents = readdir($in_dir);
closedir($in_dir);

@dir_contents = sort(@dir_contents);

foreach my $filename (@dir_contents) {
    my $title;
    (my $name, my $suffix) = $filename =~ /^(.*)(\.[^.]*)$/;
        if ($filename ne ".." and $filename ne "." and $suffix eq ".mkv") {
            my $oldtitle = `/usr/bin/mediainfo --Output="General;%Title%" $dname/$filename`;
            chomp($oldtitle);
            if ($fixtitle) {
                $title = $oldtitle;   # title, gets sanitized
            } else {
                $title = $name;   # title, gets sanitized
            }
            $title =~ s/([A-Z-])/_$1/g;
            $title =~ s/([0-9]+)/_$1/g;
            $title =~ s/_/ /g; # replace underscores with spaces
            $title =~ s/  / /g; # no double spaces
            $title =~ s/\( /\(/g; # don't do spaces after braces
            $title =~ s/^-//g; # never start with a dash
            $title =~ s/^ //g; # don't start with a space
            $title =~ s/S ([0-9]+) - E ([0-9]+)/S$1E$2/g; # fix series
            $title =~ s/S ([0-9]+) E ([0-9]+)/S$1E$2/g; # fix series
            $title =~ s/L A R P/LARP/g; # fix typical acronym
            $title =~ s/S G - 1/SG-1/g; # fix typical acronym
            $title =~ s/B Sky B/BSkyB/g; # fix typical producer
            $title =~ s/A R T E/ARTE/g; # fix typical producer
            $title =~ s/I M A X/IMAX/g; # fix typical producer
            $title =~ s/N O V A/NOVA/g; # fix typical producer
            $title =~ s/U K T V/UKTV/g; # fix typical producer
            $title =~ s/L E G O/LEGO/g;    # fix typical acronym
            $title =~ s/C N B C/CNBC/g;    # fix typical acronym
            $title =~ s/W W I I/WWII/g;    # fix typical acronym
            $title =~ s/T T I P/TTIP/g;    # fix typical acronym
            $title =~ s/N A S A/NASA/g;    # fix typical acronym
            $title =~ s/I S I S/ISIS/g;    # fix typical acronym
            $title =~ s/D Day/D-Day/g;    # fix typical acronym
            $title =~ s/A B C /ABC /g;    # fix typical producer
            $title =~ s/A R D /ARD /g;    # fix typical producer
            $title =~ s/B B C /BBC /g;    # fix typical producer
            $title =~ s/C B C /CBC /g;    # fix typical producer
            $title =~ s/D D R /DDR /g;    # fix typical producer
            $title =~ s/G D R /GDR /g;    # fix typical producer
            $title =~ s/H B O /HBO /g;    # fix typical producer
            $title =~ s/I T V /ITV /g;    # fix typical producer
            $title =~ s/N F B /NFB /g;    # fix typical producer
            $title =~ s/N B C /NBC /g;    # fix typical producer
            $title =~ s/N H K /NHK /g;    # fix typical producer
            $title =~ s/M D R /MDR /g;    # fix typical producer
            $title =~ s/O R F /ORF /g;    # fix typical producer
            $title =~ s/P B S /PBS /g;    # fix typical producer
            $title =~ s/R T L /RTL /g;    # fix typical producer
            $title =~ s/S R F /SRF /g;    # fix typical producer
            $title =~ s/S T V /STV /g;    # fix typical producer
            $title =~ s/S V T /SVT /g;    # fix typical producer
            $title =~ s/T V O /TVO /g;    # fix typical producer
            $title =~ s/W D R /WDR /g;    # fix typical producer
            $title =~ s/Z D F /ZDF /g;    # fix typical producer
            $title =~ s/Z E D /ZED /g;    # fix typical producer
            $title =~ s/Ch 4 /Ch4 /g;     # fix typical producer
            $title =~ s/T P B /TPB /g;    # fix typical acronym
            $title =~ s/H M S /HMS /g;    # fix typical acronym
            $title =~ s/N S A /NSA /g;    # fix typical acronym
            $title =~ s/U S A /USA /g;    # fix typical acronym
            $title =~ s/U S S /USS /g;    # fix typical acronym
            $title =~ s/A F K/AFK/g;    # fix typical acronym
            $title =~ s/W W 1/WW1/g;    # fix typical acronym
            $title =~ s/H M S /HMS /g;    # fix typical acronym
            $title =~ s/W W 2/WW2/g;    # fix typical acronym
            $title =~ s/S A S /SAS /g;    # fix typical acronym
            $title =~ s/G M O /GMO /g;    # fix typical acronym
            $title =~ s/T E D/TED/g;    # fix typical acronym
            $title =~ s/U S A/USA/g;    # fix typical acronym
            $title =~ s/B R /BR /g;       # fix typical producer
            $title =~ s/D C /DC /g;       # fix typical producer
            $title =~ s/N G /NG /g;       # fix typical producer
            $title =~ s/H C /HC /g;       # fix typical producer
            $title =~ s/U K /UK /g;       # fix typical acronym
            $title =~ s/U S /US /g;       # fix typical acronym
            $title =~ s/D C /DC /g;       # fix typical acronym
            if ($oldtitle eq "") { 
                $oldtitle = $title;
                if ($debug) { print "$title\n"}
                system ("/usr/bin/mkvpropedit \"$dname/$filename\" --edit info --set title=\"$oldtitle\"\n");
            } 
            if ($prefix) {
                system ("/usr/bin/mkvpropedit \"$dname/$filename\" --edit info --set title=\"$prefix$oldtitle\"\n");
            } 
            if ($fixtitle) { 
                if ($oldtitle ne $title) {
                    $oldtitle = $title;
                    if ($debug) { print "$title\n"}
                    system ("/usr/bin/mkvpropedit \"$dname/$filename\" --edit info --set title=\"$oldtitle\"\n");
                }
            } 
            if ($createnfo) {
                my $reldate = `/usr/bin/mediainfo --Output="General;%Released_Date%" $dname/$filename`;
                chomp($reldate);
                my $catnumber = `/usr/bin/mediainfo --Output="General;%CATALOG_NUMBER%" $dname/$filename`;
                chomp($catnumber);
                open (my $xmbcnfo,">", "$dname/$name.nfo");
                print $xmbcnfo "<movie>\n\t<title>$prefix$oldtitle</title>\n";
                if ($reldate ne "") {
                    print $xmbcnfo "\t<year>$reldate</year>\n";
                }
                if ($catnumber ne "") {
                    print $xmbcnfo "\t<id>$catnumber</id>\n";
                }
                print $xmbcnfo "</movie>\n";
                close ($xmbcnfo); 
            }
        }
    }

__END__

=head1 NAME

titlemkv -- puts metadata titles into mkv files and can generate .nfo
            for xmbc. needs mkvtools and mediainfo.

=head1 SYNOPSIS

B<This program> [options] [directory ...]

 Options:
   -h|--help
   -n|--nfo
   -p|--prefix

=head1 OPTIONS

=over 8

=item B<-h|--help>

Print a brief help message and exit.

=item B<-d|--debug>

Prints out debug output.

=item B<-f|--fix>

Fix title. Takes the title from the matadata and tries to sanitize it.

=item B<-n|--nfo>

Create an XML nfo-file for use with xbmc. This will be named the same
as the filename of the movie, but with the suffix .nfo. Already existing
nfo-files will be overwritten.

=item B<-p|--prefix>

Prefixes the movie title with a string of your choosing. Useful for
series that have the series-name not in the filename. 

=back

=head1 DESCRIPTION

B<This program> sets the title-tag of any mkv-file found in the 
current directory and also can generate an .nfo-file for xmbc.
It only sets the title in the mkv if it isn't already set; and 
it assumes the filenames being BiCapitalised. It processes all 
files of the directory you're in, unless given another directory. 

=cut
