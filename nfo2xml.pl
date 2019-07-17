#!/usr/bin/perl
# 
# nfo2xml -- converts xbmc metadata .nfo-files to Matroshka metadata 
#	     XML files.
# 
# Author:  Peter Keel <seegras@discordia.ch>
# Date:    21.09.2013
# Revised: 21.09.2013
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

# use module
use XML::Simple;
use Data::Dumper;
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
	if ($filename ne ".." and $filename ne "." and $suffix eq ".nfo") {
	# create object
	$xml = new XML::Simple;
	# read XML file
	$data = $xml->XMLin("$dname/$filename", suppressempty => '');
	open (XMLOUT, ">$dname/$name.xml");
	binmode(XMLOUT, ":utf8");
	print XMLOUT "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	print XMLOUT "<!DOCTYPE Tags SYSTEM \"matroskatags.dtd\">\n";
	print XMLOUT "<Tags>\n";
	# series
	if ($data->{showtitle} ne "" || $data->{set} ne "") {
	    print XMLOUT "  <Tag>\n";
	    print XMLOUT "    <Targets>\n";
	    print XMLOUT "      <TargetTypeValue>70</TargetTypeValue>\n";
	    print XMLOUT "    </Targets>\n";
	    if ($data->{set} ne "") {
		print XMLOUT "    <Simple>\n";
		print XMLOUT "      <Name>COLLECTION</Name>\n";
		print XMLOUT "      <String>$data->{set}</String>\n";
		print XMLOUT "    </Simple>\n";
	    }
	    print XMLOUT "    <Simple>\n";
	    print XMLOUT "      <Name>TITLE</Name>\n";
	    if ($data->{showtitle} ne "" && $data->{set} eq "") {
		print XMLOUT "      <String>$data->{showtitle}</String>\n";
	    } elsif ($data->{showtitle} eq "" && $data->{set} ne "") {
		print XMLOUT "      <String>$data->{set}</String>\n";
	    } 
	    print XMLOUT "    </Simple>\n";
	    foreach my $genre (@{$data->{genre}}) {
		print XMLOUT "    <Simple>\n";
	        print XMLOUT "    <Name>GENRE</Name>\n";
		print XMLOUT "	<String>$genre</String>\n";
	        print XMLOUT "    </Simple>\n";
	    }
	    print XMLOUT "  </Tag>\n";
	} 
	if ($data->{season} ne "") {
	    print XMLOUT "  <Tag>\n";
	    print XMLOUT "    <Targets>\n";
	    print XMLOUT "      <TargetTypeValue>60</TargetTypeValue>\n";
	    print XMLOUT "    </Targets>\n";
	    print XMLOUT "    <Simple>\n";
	    print XMLOUT "      <Name>PART_NUMBER</Name>\n";
	    print XMLOUT "      <String>$data->{season}</String>\n";
	    print XMLOUT "    </Simple>\n";
	    # TOTAL_PARTS unknown
	    # print XMLOUT "    <Simple>\n";
	    # print XMLOUT "      <Name>TOTAL_PARTS</Name>\n";
	    # print XMLOUT "      <String>13</String>\n";
	    # print XMLOUT "    </Simple>\n";
	    print XMLOUT "  </Tag>\n";
	}
	print XMLOUT "  <Tag>\n";
	print XMLOUT "    <Targets>\n";
	print XMLOUT "      <TargetTypeValue>50</TargetTypeValue>\n";
	print XMLOUT "    </Targets>\n";
	print XMLOUT "    <Simple>\n";
	print XMLOUT "      <Name>TITLE</Name>\n";
	print XMLOUT "      <String>$data->{title}</String>\n";
	print XMLOUT "    </Simple>\n";
	if ($data->{originaltitle} ne "") {
	    print XMLOUT "    <Simple>\n";
	    print XMLOUT "      <Name>ORIGINAL</Name>\n";
	    print XMLOUT "      <String>$data->{originaltitle}</String>\n";
	    print XMLOUT "    </Simple>\n";
	}
	if ($data->{plot} ne "") {
	    print XMLOUT "    <Simple>\n";
	    print XMLOUT "    <Name>SUMMARY</Name>\n";
	    print XMLOUT "	<String>$data->{plot}</String>\n";
	    print XMLOUT "    </Simple>\n";
	}
	if ($data->{episode} ne "") {
	    print XMLOUT "    <Simple>\n";
	    print XMLOUT "      <Name>PART_NUMBER</Name>\n";
	    print XMLOUT "      <String>$data->{episode}</String>\n";
	    print XMLOUT "    </Simple>\n";
	}
	if ($data->{year} ne "" || $data->{aired} ne "") {
	    print XMLOUT "    <Simple>\n";
	    print XMLOUT "      <Name>DATE_RELEASED</Name>\n";
	    if ($data->{year} ne "" && $data->{year} ne "0") {
		print XMLOUT "      <String>$data->{year}</String>\n";
	    } elsif ($data->{aired} ne "" && $data->{aired} ne "1969-12-31") {
		print XMLOUT "      <String>$data->{aired}</String>\n";
	    } elsif ($data->{premiered} ne "" && $data->{premiered} ne "1969-12-31") {
		print XMLOUT "      <String>$data->{premiered}</String>\n";
	    }
	    print XMLOUT "    </Simple>\n";
	}
	if(ref($data->{director}) eq 'ARRAY') {
	    foreach my $directors (@{$data->{director}}) {
		print XMLOUT "    <Simple>\n";
		print XMLOUT "      <Name>DIRECTOR</Name>\n";
		print XMLOUT "      <String>$directors</String>\n";
		print XMLOUT "    </Simple>\n";
	    }
	} elsif ($data->{director} ne "") {
	    print XMLOUT "    <Simple>\n";
	    print XMLOUT "      <Name>DIRECTOR</Name>\n";
	    print XMLOUT "      <String>$data->{director}</String>\n";
	    print XMLOUT "    </Simple>\n";
	}
	foreach my $actors (keys %{$data->{actor}}) {
	    print XMLOUT "    <Simple>\n";
	    print XMLOUT "      <Name>ACTOR</Name>\n";
	    print XMLOUT "      <String>$actors</String>\n";
	    print XMLOUT "      <Simple>\n";
	    print XMLOUT "        <Name>CHARACTER</Name>\n";
	    print XMLOUT "        <String>$data->{actor}->{$actors}->{role}</String>\n";
	    print XMLOUT "      </Simple>\n";
	    print XMLOUT "    </Simple>\n";
	}
	if(ref($data->{credits}) eq 'ARRAY') {
	    foreach my $credits (@{$data->{credits}}) {
		print XMLOUT "    <Simple>\n";
		print XMLOUT "      <Name>THANKS_TO</Name>\n";
		print XMLOUT "      <String>$credits</String>\n";
		print XMLOUT "    </Simple>\n";
	    }
	} elsif ($data->{credits} ne "") {
	    print XMLOUT "    <Simple>\n";
	    print XMLOUT "      <Name>THANKS_TO</Name>\n";
	    print XMLOUT "      <String>$data->{credits}</String>\n";
	    print XMLOUT "    </Simple>\n";
	}
	# only print genre here if no series
	if ($data->{showtitle} eq "") {
	    foreach my $genre (@{$data->{genre}}) {
		print XMLOUT "    <Simple>\n";
	        print XMLOUT "    <Name>GENRE</Name>\n";
		print XMLOUT "	<String>$genre</String>\n";
	        print XMLOUT "    </Simple>\n";
	    }
	}
	
	
	if ($data->{tmdbid} ne "") {
	    print XMLOUT "    <Simple>\n";
	    print XMLOUT "      <Name>CATALOG_NUMBER</Name>\n";
	    print XMLOUT "      <String>$data->{tmdbid}</String>\n";
	    print XMLOUT "    </Simple>\n";
	}
	if ($data->{id} ne "") {
	    print XMLOUT "    <Simple>\n";
	    print XMLOUT "      <Name>CATALOG_NUMBER</Name>\n";
	    print XMLOUT "      <String>$data->{id}</String>\n";
	    print XMLOUT "    </Simple>\n";
	}
	if ($data->{uniqueid} ne "") {
	    print XMLOUT "    <Simple>\n";
	    print XMLOUT "      <Name>CATALOG_NUMBER</Name>\n";
	    print XMLOUT "      <String>$data->{uniqueid}</String>\n";
	    print XMLOUT "    </Simple>\n";
	}
	print XMLOUT "  </Tag>\n";
	print XMLOUT "</Tags>\n";
	close (XMLOUT); 
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
