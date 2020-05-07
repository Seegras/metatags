#!/usr/bin/perl
# 
# epub-rename -- renames epub-files according to metatags 
#
# Author:  Peter Keel <seegras@discordia.ch>
# Date:    2011-01-19
# Changed: 2013-04-12
# Version: 0.9
# License: Artistic License 2.0 or MIT License
# URL:     http://seegras.discordia.ch/Programs/
# 
# Incorporates TitleCase originally by John Gruber:
# http://daringfireball.net/2008/05/title_case
# Re-written and much improved by Aristotle Pagaltzis:
# http://plasmasturm.org/code/titlecase/
# which also lies under the MIT-License.
#

use Getopt::Long;
use Pod::Usage;
use Encode;
use open qw/:std :utf8/;

my $compat;
my $debug;
my $fixtitle;
my $fixauthor;
my $fixseries;
my $needshelp;
my $rename;
my $exchange;
my $verbose;
my $dname;

&Getopt::Long::Configure( 'pass_through', 'no_autoabbrev');
&Getopt::Long::GetOptions(
    'compat|c'          => \$compat,
    'debug|d'           => \$debug,
    'fixtitle|t'        => \$fixtitle,
    'fixauthor|f'       => \$fixauthor,
    'fixseries|s'       => \$fixseries,
    'help|h'            => \$needshelp,
    'rename|r'          => \$rename,
    'exchange|x'        => \$exchange,
    'verbose|v'         => \$verbose,
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
    foreach $entry (@dir_contents) {
        if ($entry ne ".." and $entry ne ".") {
            if ($entry =~m/.*\.epub$/i) {
                $y = $entry;
                if ($compat) {
                    getmetacompat($y);
                } else {
                    getmeta($y);
                }
                if ($exchange) {
                    exchangetitle($y);
                }
                if ($fixtitle) {
                    fix_title($y);
                }
                if ($fixauthor) {
                    fix_author($y);
                }
                if ($fixseries) {
                    fix_series($y);
                }
                if ($rename) {
                    renepub();
                }
            }
        }
    }

sub exchangetitle {
    my $fname = $_[0];
    # BTW: don't check return values, they're wrong
    $fname = decode("utf-8", $fname);
    system("export LC_CTYPE=en_GB.UTF-8; ebook-meta \"$fname\" --authors=\"$oldtitle\" --title=\"$oldauth\"");
    print "changed $fname\n";
}

sub fix_title {
    my $fname = $_[0];
    if (! ($oldtitle eq $title)) {
        $fname = decode("utf-8", $fname);
        my $mytitle = $title;
        system("export LC_CTYPE=en_GB.UTF-8; ebook-meta \"$fname\" --title=\"$mytitle\"");
        print "changed $y $oldtitle to $mytitle\n";
    }
}

sub fix_series {
    my $fname = $_[0];
    my $newstr = $title;
    if ($newstr =~ m/[^#]+#?[0-9]+ ?[-:] ?.*/) {
    ($newseries, $newseriesid, $newtitle) = $newstr =~ /([^#]+)#?([0-9\.]+) ?[-:] ?(.*)/i;
    } elsif ($newstr =~ m/[^\(]+\([^#]+#?[0-9\.]+\)/) {
    ($newtitle, $newseries, $newseriesid) = $newstr =~ /([^\(]+)\(([^#]+)#?([0-9\.]+)\)/i;
    } elsif ($newstr =~ m/[^-]+-[^#]+#?[0-9\.]+/) {
    ($newtitle, $newseries, $newseriesid) = $newstr =~ /([^-]+)-([^#]+)#?([0-9\.]+)/i;
    #} elsif ($newstr =~ m/[^0-9\[]+\[[0-9]+\] ?[-:]? ?.*/) {
    #($newseries, $newseriesid, $newtitle) = $newstr =~ /^([^0-9\[]+)\[([0-9]+)\] ?[-:]? ?(.*)$/i;
    #} elsif ($newstr =~ m/[^0-9]+[0-9]+ ?[-:]? ?.*/) {
    #($newseries, $newseriesid, $newtitle) = $newstr =~ /^([^0-9]+)([0-9]+) ?[-:]? ?(.*)$/i;
    } else {
    $newseries = "";
    $newtitle = $title;
    }
    if ((! $series) && ($newseries ne "")) {
    $newseries =~ s/^\s+//;
    $newseries =~ s/\s+$//;
    $newseries =~ s/\s+/ /g;
    $newseries = ucfirst($newseries);
    $series = $newseries;
    }
    if ((! $seriesid) && $newseriesid ) {
    $newseriesid =~ s/^\s+//;
    $newseriesid =~ s/\s+$//;
    $seriesid = $newseriesid;
    }
    $newtitle =~ s/^\s+//;
    $newtitle =~ s/\s+$//;
    $newtitle = ucfirst($newtitle);

#    print "$series | $seriesid | $newtitle\n";
    
    if (! ($oldtitle eq $newtitle)) {
        $fname = decode("utf-8", $fname);
        if ($seriesid) {
            system("export LC_CTYPE=en_GB.UTF-8; ebook-meta \"$fname\" --series=\"$series\" --index=\"$seriesid\" --title=\"$newtitle\"");
        } else {
            system("export LC_CTYPE=en_GB.UTF-8; ebook-meta \"$fname\" --series=\"$series\" --title=\"$newtitle\"");
        }
    }
}

# this is intrusive, will change every file, title too
sub fix_author {
    my $fname = $_[0];
    my $newauth = "";
    my $cnt = 1;
    while ($cnt <= $authcount) {
        $newauth .= $author[$cnt];
        $cnt++;
        if ($cnt <= $authcount) {
            $newauth .= " & ";
        }
    }
    $newauth =~ s/; / & /go;
    #$newauth = encode("iso-8859-1", $newauth);
    $fname = decode("utf-8", $fname);
    #my $mytitle = encode("iso-8859-1", $title);
    $mytitle = $title;
    system("export LC_CTYPE=en_GB.UTF-8; ebook-meta \"$fname\" --title=\"$mytitle\" --authors=\"$newauth\"");
    if ($date) {
        system("export LC_CTYPE=en_GB.UTF-8; ebook-meta \"$fname\" --title=\"$mytitle\" --authors=\"$newauth\" --date=$date");
    }
    print "changed $fname $authors - $oldtitle to $newauth - $mytitle\n";
}

# FIXME: code deciding new name stupid

sub renepub {
my $counter=0;
my $exname = $newname;
$oldname = decode("utf-8", $y);
$newfullname = $dname . "/" . $newname;
$oldfullname = $dname . "/" . $oldname;
    if ($newfullname ne $oldfullname) {
        $exname = $newfullname;
        ($exname,$suffix) = $exname =~ /^(.*)(\.[^.]*)$/;
        while (-e "$newfullname") {    
            print ("WARN \"$newfullname\" exists\n");
            $counter++;
            $newfullname = $exname . "-" . $counter . $suffix;
        }
        rename ("$oldfullname", "$newfullname") unless ($newfullname eq $oldfullname);
        print ("renamed $oldfullname to \"$newfullname\"\n") unless ($newfullname eq $oldfullname);
    }
}

sub regex_author {
    my $string = $_[0];
    if ($debug) { print (stderr " string-in : '$string'\n"); };
    $string =~ s/\(Ebook By Undead\)//goi;
    $string =~ s/\[ss\]//goi;
    $string =~ s/\(ss\)//goi;
    $string =~ s/(.*)\s+\(Editor\)/Edited by $1/goi;
    $string =~ s/(.*)\s+\(Ed\)/Edited by $1/goi;
    $string =~ s/([A-Z][.])([^ ])/$1 $2/go;
    $string =~ s/([A-Z]){1,}([A-Z]){1,}\s+/$1\. $2\. /go;
    $string =~ s/([A-Z]){1,}\s+/$1\. /go;
    $string =~ s/\N{U+0060}/\'/go;
    $string =~ s/\N{U+2018}/\'/go;
    $string =~ s/\N{U+2019}/\'/go;
    $string =~ s/\N{U+201A}/\'/go;
    $string =~ s/\N{U+201B}/\'/go;
    $string =~ s/\N{U+2010}/-/go;
    $string =~ s/\N{U+2012}/-/go;
    $string =~ s/\N{U+2013}/-/go;
    $string =~ s/\N{U+2014}/-/go;
    $string =~ s/-/ /go;
    $string =~ s/\//_/go;
    $string =~ s/([A-Z]{3,})/\L$1/go;
    $string =~ s/(\w+)/\u$1/go;
    $string =~ s/  / /go;
    $string =~ s/^\s+//go;
    $string =~ s/\s+$//go;
    if ($debug) { print (stderr " string-out: '$string'\n"); };
    return $string; 
}

sub regex_title {
    my $string = $_[0];
    my $newstring = "";
    my @small_words = qw( (?<!q&)a an and as at(?!&t) but by en for if in of on or the to v[.]? via vs[.]? );
    my $small_re = join '|', @small_words;

    if ($debug) { print (stderr " string-in : '$string'\n"); };

    $string =~ s/\(\xc3\x9cbersetzung\)$//goi;
    $string =~ s/\(Übersetzung\)$//goi;
    $string =~ s/\(Original\)$//goi;
    $string =~ s/\(Dodo Press\)$//goi;
    $string =~ s/\(Epub\)$//goi;
    $string =~ s/\(German Edition\)$//goi;
    $string =~ s/\(Science-Fiction-Roman\)$//goi;
    $string =~ s/\[ss\]//goi;
    $string =~ s/\(ss\)//goi;
    $string =~ s/\(Vintage Contemporaries\)$//goi;
    $string =~ s/\(Barnes & Noble Classics Series\)$//goi;
    $string =~ s/\(Yesterday\'s Classics\)$//goi;
    $string =~ s/\([Vv][0-9]\.[0-9]\)$//goi;
    $string =~ s/\([Vv][0-9]\)$//goi;
    $string =~ s/\- [Vv][0-9]$//goi;
    $string =~ s/\s+$//go;
    $string =~ s/\(html\)$//goi;
    $string =~ s/\s+$//go;
    $string =~ s/\([0-9][0-9][0-9][0-9]\)$//goi;
    $string =~ s/\N{U+0060}/\'/go;
    $string =~ s/\N{U+2018}/\'/go;
    $string =~ s/\N{U+2019}/\'/go;
    $string =~ s/\N{U+201A}/\'/go;
    $string =~ s/\N{U+201B}/\'/go;
    $string =~ s/\N{U+2010}/-/go;
    $string =~ s/\N{U+2012}/-/go;
    $string =~ s/\N{U+2013}/-/go;
    $string =~ s/\N{U+2014}/-/go;
    $string =~ s/\ - Roman$//goi;
    $string =~ s/\//_/go;
    $string =~ s/\!//go;
    $string =~ s/\"/\'/go;
    $string =~ s/\.$//go;
    $string =~ s/-$//go;
    #$string =~ s/([\w\']+)/\u\L$1/g;
    $string =~ s/([A-Z]{3,})/\L$1/go;
    # $string =~ s/([^ (]+)/\u$1/go;
    $string =~ s/\s+/ /go;
    $string =~ s/^\s+//go;
    $string =~ s/\s+$//go;
    
    my $apos = qr/ (?: [\'] [[:lower:]]* )? /x;
    foreach ($string) {
        s{
                \b (_*) (?:
                        ( [-_[:alpha:]]+ [@.:/] [-_[:alpha:]@.:/]+ $apos ) # URL, domain, or email
                        |
                        ( (?i: $small_re ) $apos )                         # or small word (case-insensitive)
                        |
                        ( [[:alpha:]] [[:lower:]'()\[\]{}]* $apos )       # or word w/o internal caps
                        |
                        ( [[:alpha:]] [[:alpha:]'()\[\]{}]* $apos )       # or some other word
                ) (_*) \b
        }{
                $1 . (
                  defined $2 ? $2         # preserve URL, domain, or email
                : defined $3 ? "\L$3"     # lowercase small word
                : defined $4 ? "\u\L$4"   # capitalize word w/o internal caps
                : $5                      # preserve other kinds of word
                ) . $6
        }exgo;

        # exceptions for small words: capitalize at start and end of title
        s{
                (  \A [[:punct:]]*         # start of title...
                |  [:.;?!][ ]+             # or of subsentence...
                |  [ ][\'\"(\[][ ]*     )  # or of inserted subphrase...
                ( $small_re ) \b           # ... followed by small word
        }{$1\u\L$2}xigo;

        s{
                \b ( $small_re )      # small word...
                (?= [[:punct:]]* \Z   # ... at the end of the title...
                |   [\'\")\]] [ ] )   # ... or of an inserted subphrase?
        }{\u\L$1}xigo;
        $newstring .= $_;
    }
    if ($debug) { print (stderr " string-out: '$newstring'\n"); };
    return $newstring;
}

sub getmeta {
my $fname = $_[0];
open(my $meta,"<","epub-meta -atm \"$fname\"|") || die "Failed: $!\n";

$title ="";
$author ="";
$series ="";
$seriesid ="";
$authcount ="";
$auth = "";

    if ($debug) { print (stderr "$fname\n"); };

    while ( <$meta> ) {
        if ($_ =~ m/^Title: (.*)/i) {
            $title = $1;
            $oldtitle = $title;
            if ($title =~ m/\([0-9][0-9][0-9][0-9]\)$/) {
                $date = $title;
                $date =~ s/.*\(([0-9][0-9][0-9][0-9])\)$/$1/;
                if ($debug) { print (stderr " date: $date\n"); };
            };
            if ($title =~ m/(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?([0-9xX])$/) {
                # the bloody title is an ISBN instead.
                $isbn = $title;
            };
            $title = regex_title($title);
        } elsif ($_ =~ m/^Author: (aut|Author): ([^(,]*)?,([^(,]*)\(.*\(.*\).*\)/i) {
            $authcount++;
            $author[$authcount] = $3 . " " . $2;
            $oldauthor[$authcount] = $2 . " " . $3;
            $author[$authcount] = regex_author($author[$authcount]);
        } elsif ($_ =~ m/^Author: (aut|Author): ([^(,]*)?,([^(,]*)\(.*\)/i) {
            $authcount++;
            $author[$authcount] = $3 . " " . $2;
            $oldauthor[$authcount] = $2 . " " . $3;
            $author[$authcount] = regex_author($author[$authcount]);
        } elsif ($_ =~ m/^Author: (aut|Author): (.*)?\(.*\(.*\)\)/i) {
            $authcount++;
            $author[$authcount] = $2;
            $oldauthor[$authcount] = $2;
            $author[$authcount] = regex_author($author[$authcount]);
        } elsif ($_ =~ m/^Author: (aut|Author): (.*)?\(.*\)/i) {
            $authcount++;
            $author[$authcount] = $2;
            $oldauthor[$authcount] = $2;
            $author[$authcount] = regex_author($author[$authcount]);
        } elsif ($_ =~ m/^Author: (aut|Author): (.*)?,(.*)/i) {
            $authcount++;
            $author[$authcount] = $3 . " " . $2;
            $oldauthor[$authcount] = $2 . " " . $3;
            $author[$authcount] = regex_author($author[$authcount]);
        } elsif ($_ =~ m/^Author: (aut|Author): (.*)/i) {
            $authcount++;
            $author[$authcount] = $2;
            $oldauthor[$authcount] = $2;
            $author[$authcount] = regex_author($author[$authcount]);
        } elsif ($_ =~ m/^Meta: calibre:series: (.*)/i) {
            $series = $1;
            $series = regex_title($series);
            $series =~ s/-/ /go;
        } elsif ($_ =~ m/^Meta: calibre:series_index: (.*)/i) {
            $seriesid = $1;
            $seriesid = sprintf("%02d", $seriesid);
        }
    }
    if ($authcount == 0) {
        $auth = "unknown";
        $oldauth = "unknown";
    } elsif ($authcount == 1) {
        $auth = $author[1];
        $oldauth = $oldauthor[1];
    } elsif ($authcount == 2) {
        $auth = $author[1] . " & " . $author[2];
        $oldauth = $oldauthor[1] . " & " . $oldauthor[2];
    } elsif ($authcount == 3) {
        $auth = $author[1] . " & " . $author[2] . " & " . $author[3];
        $oldauth = $oldauthor[1] . " & " . $oldauthor[2] . " & " . $oldauthor[3];
    } else {
        $auth = "anthology"; 
        $oldauth = "anthology"; 
    }

    if ($series) {
        $newname = $auth . " - " . $series . $seriesid . " - " . $title . ".epub";
    }
    else {
        $newname = $auth . " - " . $title . ".epub";
    }
    if ($verbose) {
        print "$fname \"$newname\"\n"; 
    }
}

sub getmetacompat {
my $fname = $_[0];
open(my $meta,"<","ebook-meta \"$fname\"|") || die "Failed: $!\n";

$title ="";
$author ="";
$series ="";
$seriesid ="";

while ( <$meta> ) {
    if ($_ =~ m/Title               : (.*)/i) {
        $title = $1;
        $oldtitle = $title;
        $title = regex_title($title);
        if ($title =~ m/(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?([0-9xX])$/) {
        # the bloody title is an ISBN instead.
        $isbn = $title;
        }
    } elsif ($_ =~ m/Author\(s\)           : (.*)?,(.*)\[.*\]/i) {
        $author = $2 . $1;
        $author =~ regex_author($author);
    } elsif ($_ =~ m/Author\(s\)           : (.*)\[.*\]/i) {
        $author = $1;
        $author =~ regex_author($author);
    } elsif ($_ =~ m/Author\(s\)           : (.*)?,(.*)/i) {
        $author = $2 . $1;
        $author =~ regex_author($author);
    } elsif ($_ =~ m/Author\(s\)           : (.*)/i) {
        $author = $1;
        $author =~ regex_author($author);
    } elsif ($_ =~ m/Series              : (.*) \#(\d.*)/i) {
        $series = $1;
        $series = regex_title($series);
        $seriesid = $2;
        $seriesid = sprintf("%02d", $seriesid);
    }
}
if ($series) {
    $newname = $author . " - " . $series . $seriesid . " - " . $title . ".epub";
}
else {
    $newname = $author . " - " . $title . ".epub";
}
if ($verbose) {
    print "$fname \"$newname\"\n"; 
}


}
__END__

=head1 NAME

epub-rename - Rename Epub-files according to metadata

=head1 SYNOPSIS

<This program> [options] [directory ...]

 Options:
   -c|--compat
   -t|--fixtitle
   -f|--fixauthor
   -s|--fixseries
   -h|--help
   -r|--rename
   -x|--exchange
   -v|--verbose

=head1 OPTIONS

=over 8


=item B<-c|--compat>

Use ebook-meta from calibre instead of epub-meta. Much slower.

=item B<-t|--title>

Fix title. This means the tag gets sanitized, as it would if destined 
for a filename, and then written back to the metadata. Uses ebook-meta.

=item B<-s|--fixseries>

Fix series. This tries to find out the series and series-index from the 
title, sets it, and strips it from the title. Uses ebook-meta. Works 
with titles in the format "series #index - title" and some variations
thereof. 

=item B<-f|--fixauthor>

Fix all tags: author, title, and in some cases date. Uses ebook-meta
and touches every file, even those that don't need fixing. Slow.

=item B<-h|--help>

Print a brief help message and exit.

=item B<-r|--rename>

rename files to the pattern "Author - Series SeriesIndex - Title"

=item B<-x|--exchange>

changes title for author-tag and vice versa. For all those files
that have the author in the title-field and the title in the author-
field. Uses ebook-meta, thus is slow. 

=item B<-v|--verbose>

Show how all files would be renamed, not just those really renamed.

=back

=head1 DESCRIPTION

B<This program> will rename all epub-files in the directory you're in, 
unless given another directory. Per default, it will only show what
it wants to do. 

=head1 ISSUES

B<This program> needs epub-meta (from me) and ebook-meta (from Calibre)

B<1> Rename with -r first, if you see any files named 
"unknown - unknown.epub" you need to fix them first with 
ebook-convert (also from Calibre). Don't run this program 
with -f, -x, -t switches on them. 

B<2> If you're not using an UTF-8 capable terminal, you will see 
garbled output of ebook-meta. Don't worry, the file contents will
be fine.

B<3> If some idiot put a title containing commas or brackets into 
the authors field, the title will be very wrong after <This program -x>.

=cut
