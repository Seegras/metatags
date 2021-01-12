#!/usr/bin/perl
# 
# nfo2xml -- converts xbmc metadata .nfo-files to Matroshka metadata 
#	     XML files.
# 
# Author:  Peter Keel <seegras@discordia.ch>
# Date:    2013-09-21
# Revised: 2013-09-21
# Revised: 2020-05-06
# Version: 0.1
# License: Artistic License 2.0 or MIT License
# URL:     http://seegras.discordia.ch/Programs/
#
# Caveats/assumed bugs: 
# - some tags could not appear, or appear garbled when more than
#   one are present. Or vice versa. 
# - "year" and "aired" have different formats, and depending whether
#   it's a movie or a series, only one will appear. No idea what will
#   happen if DATE_RELEASED gets set to a date instead of a year.
# 
use strict;
# use module
use XML::Simple;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

my $needshelp;
my $dname;

&Getopt::Long::Configure( 'pass_through', 'no_autoabbrev');
&Getopt::Long::GetOptions(
    'help|h'    => \$needshelp,
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
    my $name; 
    my $suffix;
    ($name,$suffix) = $filename =~ /^(.*)(\.[^.]*)$/;
	if ($filename ne ".." and $filename ne "." and $suffix eq ".nfo") {
	# create object
	my $xml = new XML::Simple;
	# read XML file
	my $data = $xml->XMLin("$dname/$filename", suppressempty => '');
	open (my $out_xml, ">:encoding(UTF-8)","$dname/$name.xml");
	print $out_xml "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	print $out_xml "<!DOCTYPE Tags SYSTEM \"matroskatags.dtd\">\n";
	print $out_xml "<Tags>\n";
	# series
	if ($data->{showtitle} ne "" || $data->{set} ne "") {
	    print $out_xml "  <Tag>\n";
	    print $out_xml "    <Targets>\n";
	    print $out_xml "      <TargetTypeValue>70</TargetTypeValue>\n";
	    print $out_xml "    </Targets>\n";
	    if ($data->{set} ne "") {
		print $out_xml "    <Simple>\n";
		print $out_xml "      <Name>COLLECTION</Name>\n";
		print $out_xml "      <String>$data->{set}</String>\n";
		print $out_xml "    </Simple>\n";
	    }
	    print $out_xml "    <Simple>\n";
	    print $out_xml "      <Name>TITLE</Name>\n";
	    if ($data->{showtitle} ne "" && $data->{set} eq "") {
		print $out_xml "      <String>$data->{showtitle}</String>\n";
	    } elsif ($data->{showtitle} eq "" && $data->{set} ne "") {
		print $out_xml "      <String>$data->{set}</String>\n";
	    } 
	    print $out_xml "    </Simple>\n";
	    if(ref($data->{genre}) eq 'ARRAY') {
	        foreach my $genre (@{$data->{genre}}) {
		    print $out_xml "    <Simple>\n";
	            print $out_xml "    <Name>GENRE</Name>\n";
		    print $out_xml "	<String>$genre</String>\n";
	            print $out_xml "    </Simple>\n";
	        }
	    } elsif ($data->{genre} ne "") {
	        print $out_xml "    <Simple>\n";
	        print $out_xml "      <Name>GENRE</Name>\n";
	        print $out_xml "      <String>$data->{genre}</String>\n";
	        print $out_xml "    </Simple>\n";
	    }
	    print $out_xml "  </Tag>\n";
	} 
	if ($data->{season} ne "") {
	    print $out_xml "  <Tag>\n";
	    print $out_xml "    <Targets>\n";
	    print $out_xml "      <TargetTypeValue>60</TargetTypeValue>\n";
	    print $out_xml "    </Targets>\n";
	    print $out_xml "    <Simple>\n";
	    print $out_xml "      <Name>PART_NUMBER</Name>\n";
	    print $out_xml "      <String>$data->{season}</String>\n";
	    print $out_xml "    </Simple>\n";
	    # TOTAL_PARTS unknown
	    # print $out_xml "    <Simple>\n";
	    # print $out_xml "      <Name>TOTAL_PARTS</Name>\n";
	    # print $out_xml "      <String>13</String>\n";
	    # print $out_xml "    </Simple>\n";
	    print $out_xml "  </Tag>\n";
	}
	print $out_xml "  <Tag>\n";
	print $out_xml "    <Targets>\n";
	print $out_xml "      <TargetTypeValue>50</TargetTypeValue>\n";
	print $out_xml "    </Targets>\n";
	print $out_xml "    <Simple>\n";
	print $out_xml "      <Name>TITLE</Name>\n";
	print $out_xml "      <String>$data->{title}</String>\n";
	print $out_xml "    </Simple>\n";
	if ($data->{originaltitle} ne "") {
	    print $out_xml "    <Simple>\n";
	    print $out_xml "      <Name>ORIGINAL</Name>\n";
	    print $out_xml "      <String>$data->{originaltitle}</String>\n";
	    print $out_xml "    </Simple>\n";
	}
	if ($data->{plot} ne "") {
	    print $out_xml "    <Simple>\n";
	    print $out_xml "    <Name>SUMMARY</Name>\n";
	    print $out_xml "	<String>$data->{plot}</String>\n";
	    print $out_xml "    </Simple>\n";
	}
	if ($data->{episode} ne "") {
	    print $out_xml "    <Simple>\n";
	    print $out_xml "      <Name>PART_NUMBER</Name>\n";
	    print $out_xml "      <String>$data->{episode}</String>\n";
	    print $out_xml "    </Simple>\n";
	}
	if ($data->{year} ne "" || $data->{aired} ne "") {
	    print $out_xml "    <Simple>\n";
	    print $out_xml "      <Name>DATE_RELEASED</Name>\n";
	    if ($data->{year} ne "" && $data->{year} ne "0") {
		print $out_xml "      <String>$data->{year}</String>\n";
	    } elsif ($data->{aired} ne "" && $data->{aired} ne "1969-12-31") {
		print $out_xml "      <String>$data->{aired}</String>\n";
	    } elsif ($data->{premiered} ne "" && $data->{premiered} ne "1969-12-31") {
		print $out_xml "      <String>$data->{premiered}</String>\n";
	    }
	    print $out_xml "    </Simple>\n";
	}
	if(ref($data->{director}) eq 'ARRAY') {
	    foreach my $directors (@{$data->{director}}) {
		print $out_xml "    <Simple>\n";
		print $out_xml "      <Name>DIRECTOR</Name>\n";
		print $out_xml "      <String>$directors</String>\n";
		print $out_xml "    </Simple>\n";
	    }
	} elsif ($data->{director} ne "") {
	    print $out_xml "    <Simple>\n";
	    print $out_xml "      <Name>DIRECTOR</Name>\n";
	    print $out_xml "      <String>$data->{director}</String>\n";
	    print $out_xml "    </Simple>\n";
	}
	foreach my $actors (keys %{$data->{actor}}) {
	    print $out_xml "    <Simple>\n";
	    print $out_xml "      <Name>ACTOR</Name>\n";
	    print $out_xml "      <String>$actors</String>\n";
	    print $out_xml "      <Simple>\n";
	    print $out_xml "        <Name>CHARACTER</Name>\n";
	    print $out_xml "        <String>$data->{actor}->{$actors}->{role}</String>\n";
	    print $out_xml "      </Simple>\n";
	    print $out_xml "    </Simple>\n";
	}
	if(ref($data->{credits}) eq 'ARRAY') {
	    foreach my $credits (@{$data->{credits}}) {
		print $out_xml "    <Simple>\n";
		print $out_xml "      <Name>THANKS_TO</Name>\n";
		print $out_xml "      <String>$credits</String>\n";
		print $out_xml "    </Simple>\n";
	    }
	} elsif ($data->{credits} ne "") {
	    print $out_xml "    <Simple>\n";
	    print $out_xml "      <Name>THANKS_TO</Name>\n";
	    print $out_xml "      <String>$data->{credits}</String>\n";
	    print $out_xml "    </Simple>\n";
	}
	# only print genre here if no series
	if ($data->{showtitle} eq "") {
	    if(ref($data->{genre}) eq 'ARRAY') {
	        foreach my $genre (@{$data->{genre}}) {
		    print $out_xml "    <Simple>\n";
	            print $out_xml "    <Name>GENRE</Name>\n";
		    print $out_xml "	<String>$genre</String>\n";
	            print $out_xml "    </Simple>\n";
	        }
	    } elsif ($data->{genre} ne "") {
	        print $out_xml "    <Simple>\n";
	        print $out_xml "      <Name>GENRE</Name>\n";
	        print $out_xml "      <String>$data->{genre}</String>\n";
	        print $out_xml "    </Simple>\n";
	    }
	}
	
	if ($data->{tmdbid} ne "") {
	    print $out_xml "    <Simple>\n";
	    print $out_xml "      <Name>CATALOG_NUMBER</Name>\n";
	    print $out_xml "      <String>$data->{tmdbid}</String>\n";
	    print $out_xml "    </Simple>\n";
	}
	if ($data->{id} ne "") {
	    print $out_xml "    <Simple>\n";
	    print $out_xml "      <Name>CATALOG_NUMBER</Name>\n";
	    print $out_xml "      <String>$data->{id}</String>\n";
	    print $out_xml "    </Simple>\n";
	}
	if ($data->{uniqueid} ne "") {
	    print $out_xml "    <Simple>\n";
	    print $out_xml "      <Name>CATALOG_NUMBER</Name>\n";
	    print $out_xml "      <String>$data->{uniqueid}</String>\n";
	    print $out_xml "    </Simple>\n";
	}
	print $out_xml "  </Tag>\n";
	print $out_xml "</Tags>\n";
	close ($out_xml); 
	}
    }

__END__

=head1 NAME

nfo2xml -- converts xbmc metadata .nfo-files to Matroshka metadata 
           XML files.

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

B<This program> converts converts xbmc metadata .nfo-files to 
Matroshka metadata XML files.

With the XML files you can set the embedded metadata of Matroshka
files like this: mkvpropedit --tags all:target.xml target.mkv

=cut
