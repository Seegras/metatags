#!/usr/bin/perl
# 
# thek2xml -- converts mediathek metadata .txt-files to Matroshka metadata 
#	      XML files.
# 
# Author:  Peter Keel <seegras@discordia.ch>
# Date:    27.01.2015
# Revised: 28.01.2015
# Version: 0.2
# License: Artistic License 2.0 or MIT License
# URL:     http://seegras.discordia.ch/Programs/
#
# Caveats: This was done within an hour late at night, so bugs are expected.
#

use Getopt::Long;
use Pod::Usage;

&Getopt::Long::Configure( 'pass_through', 'no_autoabbrev');
&Getopt::Long::GetOptions(
		'help|h'		=> \$needshelp,
);

if (!$ARGV[0]) {
    $dname = ".";
} else { 
    $dname=$ARGV[0]; 
}

if ($needshelp) {
pod2usage(1);
}

opendir(IN_DIR, $dname) || die "I am unable to access that directory...Sorry";
@dir_contents = readdir(IN_DIR);
closedir(IN_DIR);

@dir_contents = sort(@dir_contents);
    foreach $filename (@dir_contents) {
    ($name,$suffix) = $filename =~ /^(.*)(\.[^.]*)$/;
	if ($filename ne ".." and $filename ne "." and $suffix eq ".txt") {

        open (TXTIN,"$dname/$filename");

	my @array; {
	    local $/ = '';
	    @array = <TXTIN>;
	}

	close (TXTIN);

	# my @lines = split /\n/, $array[0];
	while($array[0] =~ /([^\n]+)\n?/g){
		$line = $1;
		if ($line =~ s/Sender:\s(\S*)/$1/) {
		    # $1 =~ s/Sender:\s(\S)\n.*/$1/;
		    $sender = $line;
		    $sender =~ s/^\s+//;
		}
		if ($line =~ s/Thema:\s(\S*)/$1/) {
		    $thema = $line;
		    $thema =~ s/^\s+//;
		}
	}
	#print ("Sender: ", $sender, "\n");
	#print ("Theme: ", $thema, "\n");
	if ($array[1] =~ s/Titel:\s(\S*)/$1/) {
	    $title = $array[1];
	    $title =~ s/^\s+|\s+$//g
	}
	#print ("Title: ", $title, "\n");
	while($array[2] =~ /([^\n]+)\n?/g){
	    $line = $1;
	    if ($line =~ s/Datum:\s(\S*)/$1/) {
		$datum = $line;
		$datum =~ s/^\s+//;
		my @date = split(/\./, $datum);
		$intdate = $date[2]."-".$date[1]."-".$date[0];
	    }
	}
	# print ("Date: ", $datum, "\n");
        #print $array[3];
	if ($array[3] =~ s/Website\\n(\S*)/$1/) {
	    $url = $array[3];
	    $url =~ s/^\s+|\s+$//g
	}
	if ($array[4] =~ s/[Uu][Rr][Ll]\n(\S*)/$1/) {
	    $urlrtmp = $array[4];
	    $urlrtmp =~ s/^\s+|\s+$//g
	}
	# print ("URL: ", $url, "\n");
	# print ("RTMP: ", $urlrtmp, "\n");
        $summary = $array[5];
	$summary =~ s/\n/ /g;
	$summary =~ s/\r/ /g;
	$summary =~ s/  / /g;
	$summary =~ s/<br>/ /g;
	$summary =~ s/<br\/>/ /g;
	$summary =~ s/^\s+|\s+$//g;
	open (XMLOUT, ">$dname/$name.xml");
	# binmode(XMLOUT, ":utf8");
	print XMLOUT "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	print XMLOUT "<!DOCTYPE Tags SYSTEM \"matroskatags.dtd\">\n";
	print XMLOUT "<Tags>\n";
	print XMLOUT "  <Tag>\n";
	print XMLOUT "    <Targets>\n";
	print XMLOUT "      <TargetTypeValue>50</TargetTypeValue>\n";
	print XMLOUT "    </Targets>\n";
	print XMLOUT "    <Simple>\n";
	print XMLOUT "      <Name>TITLE</Name>\n";
	print XMLOUT "      <String>$title</String>\n";
	print XMLOUT "    </Simple>\n";
	print XMLOUT "    <Simple>\n";
	print XMLOUT "      <Name>SUBJECT</Name>\n";
	print XMLOUT "      <String>$thema</String>\n";
	print XMLOUT "    </Simple>\n";
	print XMLOUT "    <Simple>\n";
	print XMLOUT "      <Name>PUBLISHER</Name>\n";
	print XMLOUT "      <String>$sender</String>\n";
	print XMLOUT "    </Simple>\n";
	print XMLOUT "    <Simple>\n";
	print XMLOUT "      <Name>SUMMARY</Name>\n";
	print XMLOUT "      <String>$summary</String>\n";
	print XMLOUT "    </Simple>\n";
	print XMLOUT "    <Simple>\n";
	print XMLOUT "      <Name>URL</Name>\n";
	print XMLOUT "      <String>$url</String>\n";
	print XMLOUT "    </Simple>\n";
	print XMLOUT "    <Simple>\n";
	print XMLOUT "      <Name>DATE_RELEASED</Name>\n";
	print XMLOUT "      <String>$intdate</String>\n";
	print XMLOUT "    </Simple>\n";
	print XMLOUT "  </Tag>\n";
	print XMLOUT "</Tags>\n";
	close (XMLOUT); 
	}

    }

__END__

=head1 NAME

thek2xml -- converts mediathek metadata .txt-files to Matroshka metadata 
#	    XML files.

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

B<This program> converts converts mediathek metadata .txt-files to 
Matroshka metadata XML files.

With the XML files you can set the embedded metadata of Matroshka
files like this: mkvpropedit --tags all:target.xml target.mkv

=cut
