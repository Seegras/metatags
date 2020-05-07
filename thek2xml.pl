#!/usr/bin/perl
# 
# thek2xml -- converts mediathek metadata .txt-files to Matroshka metadata 
#	      XML files.
# 
# Author:  Peter Keel <seegras@discordia.ch>
# Date:    2015-01-27
# Revised: 2015-01-28
# Revised: 2020-05-06
# Version: 0.3
# License: Artistic License 2.0 or MIT License
# URL:     http://seegras.discordia.ch/Programs/
#
# Caveats: This was done within an hour late at night, so bugs are expected.
#
use strict;
use Getopt::Long;
use Pod::Usage;

my $needshelp;
my $dname;

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

opendir(my $in_dir, $dname) || die "I am unable to access that directory...Sorry";
my @dir_contents = readdir($in_dir);
closedir($in_dir);

@dir_contents = sort(@dir_contents);
    foreach my $filename (@dir_contents) {
    my $title;
    my $sender;
    my $thema;
    my $summary;
    my $intdate;
    my $datum;
    my $url;
    my $urlrtmp;
    my $line;

    (my $name, my $suffix) = $filename =~ /^(.*)(\.[^.]*)$/;
	if ($filename ne ".." and $filename ne "." and $suffix eq ".txt") {

        open (my $in_txt,"<","$dname/$filename");

	my @array; {
	    local $/ = '';
	    @array = <$in_txt>;
	}

	close ($in_txt);

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
	open (my $out_xml, ">","$dname/$name.xml");
	# binmode($out_xml, ":utf8");
	print $out_xml "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	print $out_xml "<!DOCTYPE Tags SYSTEM \"matroskatags.dtd\">\n";
	print $out_xml "<Tags>\n";
	print $out_xml "  <Tag>\n";
	print $out_xml "    <Targets>\n";
	print $out_xml "      <TargetTypeValue>50</TargetTypeValue>\n";
	print $out_xml "    </Targets>\n";
	print $out_xml "    <Simple>\n";
	print $out_xml "      <Name>TITLE</Name>\n";
	print $out_xml "      <String>$title</String>\n";
	print $out_xml "    </Simple>\n";
	print $out_xml "    <Simple>\n";
	print $out_xml "      <Name>SUBJECT</Name>\n";
	print $out_xml "      <String>$thema</String>\n";
	print $out_xml "    </Simple>\n";
	print $out_xml "    <Simple>\n";
	print $out_xml "      <Name>PUBLISHER</Name>\n";
	print $out_xml "      <String>$sender</String>\n";
	print $out_xml "    </Simple>\n";
	print $out_xml "    <Simple>\n";
	print $out_xml "      <Name>SUMMARY</Name>\n";
	print $out_xml "      <String>$summary</String>\n";
	print $out_xml "    </Simple>\n";
	print $out_xml "    <Simple>\n";
	print $out_xml "      <Name>URL</Name>\n";
	print $out_xml "      <String>$url</String>\n";
	print $out_xml "    </Simple>\n";
	print $out_xml "    <Simple>\n";
	print $out_xml "      <Name>DATE_RELEASED</Name>\n";
	print $out_xml "      <String>$intdate</String>\n";
	print $out_xml "    </Simple>\n";
	print $out_xml "  </Tag>\n";
	print $out_xml "</Tags>\n";
	close ($out_xml); 
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
