#!/usr/bin/perl
#
# exif-meta -- tries to fix and set exif/xmp metatags for pdf files.
#
# Author:  Peter Keel <seegras@discordia.ch>
# Date:    2011-04-11
# Revised: 2014-03-16
# Revised: 2020-05-06
# Version: 0.9
# License: Artistic License 2.0 or MIT License
# URL:     http://seegras.discordia.ch/Programs/
#
use strict;
use Getopt::Long;
use Pod::Usage;
use File::Basename;
use File::Copy;
use Path::Class;
use Cwd; 
use Image::ExifTool qw(:Public);

my $needshelp;
my $forcetitle;
my $fixpdf;
my $f_authortitle;
my $f_titleauthor;
my $f_title;
my $f_prefix;
my $bicap;
my $write;
my $dname;
my $debug;

&Getopt::Long::Configure( 'pass_through', 'no_autoabbrev');
&Getopt::Long::GetOptions(
    'help|h'                    => \$needshelp,
    'force|f'                   => \$forcetitle,
    'fix'                       => \$fixpdf,
    'format-authorttitle|a'     => \$f_authortitle,
    'format-titleauthor|x'      => \$f_titleauthor,
    'format-title|t'            => \$f_title,
    'format-prefix|p'           => \$f_prefix,
    'bicap|b'                   => \$bicap,
    'write|w'                   => \$write,
);

if (!$ARGV[0]) {
    $dname = ".";
} else { 
    $dname=$ARGV[0]; 
}

if ($needshelp) {
    pod2usage(1);
}

sub cleanex {
    my $string = $_[0];
    if ($debug) { print (stderr " string-in : '$string'\n"); };
    $string =~ s/^\s+//go;
    $string =~ s/  / /g;
    $string =~ s/\(pdf\)//; 
    $string =~ s/\(v?[0-9]\.[0-9]\)//;
    $string =~ s/\s+$//go;
    $string =~ s/-$//go;
    $string =~ s/\s+$//go;
    if ($debug) { print (stderr " string-out: '$string'\n"); };
    return $string; 
}

sub regex_author {
    my $string = $_[0];
    if ($debug) { print (stderr " string-in : '$string'\n"); };
    $string =~ s/^HeMan007$//goi;
    $string =~ s/^By   for www$//goi;
    $string =~ s/^ACDSee PDF Image.$//goi;
    $string =~ s/^ripped by tIgEr$//goi;
    $string =~ s/^Scann by WodkaEde \(Verleihnix\)$//goi;
    $string =~ s/^published by T-Rex$//goi;
    $string =~ s/^scanned by berlin_bookworm$//goi;
    $string =~ s/^Scanned by JoeBar$//goi;
    $string =~ s/^Scanned by Dr.Gonzo$//goi;
    $string =~ s/^Scanned by Belfegor17$//goi;
    $string =~ s/^scanned by darksfere$//goi;
    $string =~ s/^PDF conversion by wantsomfet$//goi;
    $string =~ s/^_ThE_UnKnOwN_$//goi;
    $string =~ s/^Locutus$//goi;
    $string =~ s/^Wolfgang$//goi;
    $string =~ s/^Claire$//goi;
    $string =~ s/^Haut$//goi;
    $string =~ s/^Spittel$//goi;
    $string =~ s/^None of your Business$//goi;
    $string =~ s/^Team Elements$//goi;
    $string =~ s/^Team Liberty$//goi;
    $string =~ s/^Harry$//goi;
    $string =~ s/^Hubert$//goi;
    $string =~ s/^Игорь$//goi;
    $string =~ s/^ich sitze ohne päus\´l, den ganzen tag aufm häus\´l$//goi;
    $string =~ s/^martin1$//goi;
    $string =~ s/^darksfere$//goi;
    $string =~ s/^mondenkinder$//goi;
    $string =~ s/^Moertel$//goi;
    $string =~ s/^Michel$//goi;
    $string =~ s/^Nicht zum Verkauf\! Scan Manu$//goi;
    $string =~ s/^Nichtznuts$//goi;
    $string =~ s/^nicki$//goi;
    $string =~ s/^Nicki$//goi;
    $string =~ s/^The MOGUL of LAHORE$//goi;
    $string =~ s/^ReinerZufall$//goi;
    $string =~ s/^Peter Pan$//goi;
    $string =~ s/^Harribo$//goi;
    $string =~ s/^Fred$//goi;
    $string =~ s/^Russel$//goi;
    $string =~ s/^RoRi74$//goi;
    $string =~ s/^RedStarBurner$//goi;
    $string =~ s/^ramses$//goi;
    $string =~ s/^Ramaweb$//goi;
    $string =~ s/^Rainbow$//goi;
    $string =~ s/^Pegasus37$//goi;
    $string =~ s/^QWERTY$//goi;
    $string =~ s/^probiers aus$//goi;
    $string =~ s/^gerd$//goi;
    $string =~ s/^schaber$//goi;
    $string =~ s/^roland$//goi;
    $string =~ s/^michaela$//goi;
    $string =~ s/^nanu$//goi;
    $string =~ s/^huynh$//goi;
    $string =~ s/^marit$//goi;
    $string =~ s/^pegasux$//goi;
    $string =~ s/^olivier$//goi;
    $string =~ s/^Mutsch$//goi;
    $string =~ s/^Azrael$//goi;
    $string =~ s/^Vogel$//goi;
    $string =~ s/^Crest$//goi;
    $string =~ s/^Hetz$//goi;
    $string =~ s/^berl$//goi;
    $string =~ s/^weiler$//goi;
    $string =~ s/^skadi$//goi;
    $string =~ s/^meister$//goi;
    $string =~ s/^Jack$//goi;
    $string =~ s/^furz$//goi;
    $string =~ s/^Gamer$//goi;
    $string =~ s/^Engel 07$//goi;
    $string =~ s/^Zweier ohne$//goi;
    $string =~ s/^indy$//goi;
    $string =~ s/^Hanni$//goi;
    $string =~ s/^Gina$//goi;
    $string =~ s/^Ursula$//goi;
    $string =~ s/^Troll$//goi;
    $string =~ s/^tolot001$//goi;
    $string =~ s/^Thracker$//goi;
    $string =~ s/^Thor$//goi;
    $string =~ s/^schwarze witwe$//goi;
    $string =~ s/^skadi$//goi;
    $string =~ s/^Steffen$//goi;
    $string =~ s/^Spellbinder$//goi;
    $string =~ s/^the boss$//goi;
    $string =~ s/^stoertebeker$//goi;
    $string =~ s/^TBH$//goi;
    $string =~ s/^kram$//goi;
    $string =~ s/^martin1$//goi;
    $string =~ s/^vaseline$//goi;
    $string =~ s/^Team ATTiCA$//goi;
    $string =~ s/^Schlesinger$//goi;
    $string =~ s/^kanti$//goi;
    $string =~ s/^virusscript$//goi;
    $string =~ s/^Timm$//goi;
    $string =~ s/^Michael$//goi;
    $string =~ s/^bigknaller$//goi;
    $string =~ s/^Hirsel3D$//goi;
    $string =~ s/^BloRakane$//goi;
    $string =~ s/^Zoobesucher$//goi;
    $string =~ s/^Kati$//goi;
    $string =~ s/^Ralf$//goi;
    $string =~ s/^Wolf$//goi;
    $string =~ s/^www_k2pdf_com$//goi;
    $string =~ s/^microwar$//goi;
    $string =~ s/^RoliRazor$//goi;
    $string =~ s/^1ygrp$//goi;
    $string =~ s/^silk$//goi;
    $string =~ s/^syc\@a2\@hub-rz$//goi;
    $string =~ s/^mac13$//goi;
    $string =~ s/^naruchan$//goi;
    $string =~ s/^vitzliputzli$//goi;
    $string =~ s/^fish$//goi;
    $string =~ s/^Marco$//goi;
    $string =~ s/^Zentaur$//goi;
    $string =~ s/^Jana$//goi;
    $string =~ s/^coca$//goi;
    $string =~ s/^Vocki$//goi;
    $string =~ s/^karla$//goi;
    $string =~ s/^—÷l\@MK2$//goi;
    $string =~ s/^Name\@HENRY$//goi;
    $string =~ s/^wendland$//goi;
    $string =~ s/^Maus$//goi;
    $string =~ s/^ipn1$//goi;
    $string =~ s/^1002$//goi;
    $string =~ s/^d.r-$//goi;
    $string =~ s/^illa$//goi;
    $string =~ s/^prat$//goi;
    $string =~ s/^Monty$//goi;
    $string =~ s/^Jens$//goi;
    $string =~ s/^nickles$//goi;
    $string =~ s/^Thomas$//goi;
    $string =~ s/^Atterdag$//goi;
    $string =~ s/^Pentium$//goi;
    $string =~ s/^rupert$//goi;
    $string =~ s/^skunk$//goi;
    $string =~ s/^Freund$//goi;
    $string =~ s/^Philippi$//goi;
    $string =~ s/^macska$//goi;
    $string =~ s/^L cia$//goi;
    $string =~ s/^Jojo$//goi;
    $string =~ s/^ving$//goi;
    $string =~ s/^hans$//goi;
    $string =~ s/^Jörg$//goi;
    $string =~ s/^englaen$//goi;
    $string =~ s/^OEM2\@HOTEL$//goi;
    $string =~ s/^slavia$//goi;
    $string =~ s/^tina$//goi;
    $string =~ s/^xanthos$//goi;
    $string =~ s/^jorgi$//goi;
    $string =~ s/^Petra$//goi;
    $string =~ s/^irgend jemand$//goi;
    $string =~ s/^c20021$//goi;
    $string =~ s/^a984wja$//goi;
    $string =~ s/^\[\(-\+-sUppLeX-\+-\)\]$//goi;
    $string =~ s/^Phoreos$//goi;
    $string =~ s/^registered user$//goi;
    $string =~ s/^Ente Quak$//goi;
    $string =~ s/^eroticgeist$//goi;
    $string =~ s/^Andy$//goi;
    $string =~ s/^Thor\'s Hammer$//goi;
    $string =~ s/^Olga$//goi;
    $string =~ s/^Armin$//goi;
    $string =~ s/^jojox$//goi;
    $string =~ s/^waldi$//goi;
    $string =~ s/^Mathaswintha$//goi;
    $string =~ s/^fc011774$//goi;
    $string =~ s/^xqf1011$//goi;
    $string =~ s/^ulrike steffans$//goi;
    $string =~ s/^Merle$//goi;
    $string =~ s/^Kerstin$//goi;
    $string =~ s/^ccccccc$//goi;
    $string =~ s/^achim$//goi;
    $string =~ s/^elements$//goi;
    $string =~ s/^cardenal$//goi;
    $string =~ s/^Dumme Pute$//goi;
    $string =~ s/^PUSCHELPFOTE$//goi;
    $string =~ s/^Complan \| LPG$//goi;
    $string =~ s/^PC-MPI-K$//goi;
    $string =~ s/^ReiAngel2k\@REIANGEL2K$//goi;
    $string =~ s/^umineko$//goi;
    $string =~ s/^george$//goi;
    $string =~ s/^Allgemein$//goi;
    $string =~ s/^13ter$//goi;
    $string =~ s/^akascha$//goi;
    $string =~ s/^LEGION$//goi;
    $string =~ s/^htacken$//goi;
    $string =~ s/^Mac10$//goi;
    $string =~ s/^Pano$//goi;
    $string =~ s/^Filip$//goi;
    $string =~ s/^Fallaci$//goi;
    $string =~ s/^Frank$//goi;
    $string =~ s/^Karl$//goi;
    $string =~ s/^Robby$//goi;
    $string =~ s/^Bubble$//goi;
    $string =~ s/^Werner$//goi;
    $string =~ s/^Talia$//goi;
    $string =~ s/^Morton$//goi;
    $string =~ s/^Kahane$//goi;
    $string =~ s/^Boya$//goi;
    $string =~ s/^Fritz$//goi;
    $string =~ s/^Eltern$//goi;
    $string =~ s/^Raidy$//goi;
    $string =~ s/^KREPKE$//goi;
    $string =~ s/^www_k2pdf_com$//goi;
    $string =~ s/^Hammer$//goi;
    $string =~ s/^Mathias$//goi;
    $string =~ s/^Ford Perfect$//goi;
    $string =~ s/^ARMIN DEUS$//goi;
    $string =~ s/^Tajinder Sandhu$//goi;
    $string =~ s/^grumf$//goi;
    $string =~ s/^madraxx$//goi;
    $string =~ s/^Sunny$//goi;
    $string =~ s/^test$//goi;
    $string =~ s/^Cara$//goi;
    $string =~ s/^Shaya$//goi;
    $string =~ s/^tafi$//goi;
    $string =~ s/^jhhgf$//goi;
    $string =~ s/^KoopaOne$//goi;
    $string =~ s/^klaus$//goi;
    $string =~ s/^JAU\@JAU$//goi;
    $string =~ s/^hochwuerdin//goi;
    $string =~ s/^Jupp$//goi;
    $string =~ s/^MasterDarkness$//goi;
    $string =~ s/^Karl Napf$//goi;
    $string =~ s/^Hyphyse \/ Ramaweb$//goi;
    $string =~ s/^Mustafa$//goi;
    $string =~ s/^Alpha Centauri$//goi;
    $string =~ s/^Keltenrächer$//goi;
    $string =~ s/^Jezebel$//goi;
    $string =~ s/^TechnoCrack$//goi;
    $string =~ s/^XXX\@COMPI$//goi;
    $string =~ s/^Oldie$//goi;
    $string =~ s/^Bio - Anbau$//goi;
    $string =~ s/^readersplanet 2001, MMTC GmbH$//goi;
    $string =~ s/^RENAMEDBYADMWHILEHIDDENTOALLOWDUPLICATEACCELERATORS$//goi;
    $string =~ s/^Frohsinn$//goi;
    $string =~ s/^xxxxx$//goi;
    $string =~ s/^dago33$//goi;
    $string =~ s/^xxxxxxx$//goi;
    $string =~ s/^almut$//goi;
    $string =~ s/^fahrenht$//goi;
    $string =~ s/^waldschrat$//goi;
    $string =~ s/^Andi20LD$//goi;
    $string =~ s/^SF-Online$//goi;
    $string =~ s/^Tigerliebe$//goi;
    $string =~ s/^Charlo von der Birke$//goi;
    $string =~ s/^Warthog2000$//goi;
    $string =~ s/^Sandini$//goi;
    $string =~ s/^Sandini Scan$//goi;
    $string =~ s/^Sandini Scan \& PDF$//goi;
    $string =~ s/^eBook: sadu$//goi;
    $string =~ s/^MK\@trix$//goi;
    $string =~ s/^\*\*\*\*\*\*\*$//goi;
    $string =~ s/^Ã$//goi;
    $string =~ s/^aaaa$//goi;
    $string =~ s/^Abraham0815$//goi;
    $string =~ s/^Andi$//goi;
    $string =~ s/^Andrea$//goi;
    $string =~ s/^AnyBody$//goi;
    $string =~ s/^AP04$//goi;
    $string =~ s/^Archangel2003$//goi;
    $string =~ s/^AT4TAFI1$//goi;
    $string =~ s/^Aub$//goi;
    $string =~ s/^B�$//goi;
    $string =~ s/^BAPPEM$//goi;
    $string =~ s/^bbb$//goi;
    $string =~ s/^Bogdan Dumala$//goi;
    $string =~ s/^Bearbeitet von Volieme$//goi;
    $string =~ s/^BergFex1$//goi;
    $string =~ s/^blfn$//goi;
    $string =~ s/^blondi$//goi;
    $string =~ s/^bloodronin$//goi;
    $string =~ s/^bookmanX$//goi;
    $string =~ s/^bookworm$//goi;
    $string =~ s/^SchmauKe$//goi;
    $string =~ s/^Berta Butz$//goi;
    $string =~ s/^buddelkastenpeterle$//goi;
    $string =~ s/^Cat666$//goi;
    $string =~ s/^charity$//goi;
    $string =~ s/^Chemo13$//goi;
    $string =~ s/^chuyang$//goi;
    $string =~ s/^clearsky$//goi;
    $string =~ s/^Coolmann22$//goi;
    $string =~ s/^crazy2001$//goi;
    $string =~ s/^Crazy2001 \/ klr$//goi;
    $string =~ s/^dbc pierre$//goi;
    $string =~ s/^dideldi$//goi;
    $string =~ s/^die-gaskranken$//goi;
    $string =~ s/^dln$//goi;
    $string =~ s/^gilles04$//goi;
    $string =~ s/^Doedel$//goi;
    $string =~ s/^dtv$//goi;
    $string =~ s/^dusel$//goi;
    $string =~ s/^Eingescannt und Berabeitet Bitland$//goi;
    $string =~ s/^EXDE04E6$//goi;
    $string =~ s/^Friend$//goi;
    $string =~ s/^loer$//goi;

    # TLA / Initials - maybe we should clear them all.
    $string =~ s/^dll$//goi;
    $string =~ s/^xxx$//goi;
    $string =~ s/^SMM$//goi;
    $string =~ s/^öll$//goi;
    $string =~ s/^vis$//goi;
    $string =~ s/^ffg$//goi;
    $string =~ s/^pxd$//goi;
    $string =~ s/^Alf$//goi;
    $string =~ s/^pop$//goi;
    $string =~ s/^Udr$//goi;
    $string =~ s/^Doc$//goi;
    $string =~ s/^KdH$//goi;
    $string =~ s/^dfg$//goi;
    $string =~ s/^abc$//goi;
    $string =~ s/^dtv$//goi;
    $string =~ s/^dln$//goi;
    $string =~ s/^ela$//goi;
    $string =~ s/^Ché$//goi;
    $string =~ s/^tim$//goi;
    $string =~ s/^a b$//goi;
    $string =~ s/^bac$//goi;
    $string =~ s/^bla$//goi;
    $string =~ s/^WiP$//goi;
    $string =~ s/^xyz$//goi;
    $string =~ s/^Zen$//goi;
    $string =~ s/^SPA$//goi;
    $string =~ s/^fis$//goi;
    $string =~ s/^ich$//goi;
    $string =~ s/^Ute$//goi;
    $string =~ s/^olm$//goi;
    $string =~ s/^Tia$//goi;
    $string =~ s/^det$//goi;
    $string =~ s/^rob$//goi;
    $string =~ s/^Max$//goi;
    $string =~ s/^mar$//goi;
    $string =~ s/^JHN$//goi;
    $string =~ s/^sds$//goi;
    $string =~ s/^lex$//goi;
    $string =~ s/^Uwe$//goi;
    $string =~ s/^mfg$//goi;
    $string =~ s/^ÿþD$//goi;
    $string =~ s/^ÿþi$//goi;
    $string =~ s/^ÿþC$//goi;
    $string =~ s/^ÿþc$//goi;
    $string =~ s/^x\@X$//goi;
    $string =~ s/^Shilahr$//goi;
    $string =~ s/^Krieger$//goi;
    $string =~ s/^Corben$//goi;
    $string =~ s/^Heinz$//goi;
    $string =~ s/^¶ll$//goi;
    $string =~ s/^leck mich$//goi;
    $string =~ s/^Clavel$//goi;
    $string =~ s/^joachim$//goi;
    $string =~ s/^Karpo$//goi;
    $string =~ s/^Mallory$//goi;
    $string =~ s/^Eagleeye$//goi;
    $string =~ s/^der Zünder$//goi;
    $string =~ s/^Manndi$//goi;
    $string =~ s/^hom keehn pfeng$//goi;
    $string =~ s/^\/ klr$//goi;
    $string =~ s/^Fuentes$//goi;
    $string =~ s/^Henry$//goi;
    $string =~ s/^Manu$//goi;
    $string =~ s/^Abakus$//goi;
    $string =~ s/^Ghost$//goi;
    $string =~ s/^Paulchen$//goi;
    $string =~ s/^Ramses 2nd$//goi;
    $string =~ s/^\?rbel /Bärbel /goi;
    $string =~ s/^k430494$//goi;
    $string =~ s/^\*\*\*$//goi;
    $string =~ s/^Perry Rhodan$//goi;
    $string =~ s/^Sabine Frantzen$//goi;
    # Fix known authors
    $string =~ s/^Dean Koontz$/Dean R. Koontz/goi;
    $string =~ s/^Dean R Koontz$/Dean R. Koontz/goi;
    $string =~ s/^Koontz, Dean R.$/Dean R. Koontz/goi;
    $string =~ s/^c.s.forester$/C. S. Forester/goi;
    $string =~ s/^CS Forester$/C. S. Forester/goi;
    $string =~ s/^Angela Sommer Bodenburg$/Angela Sommer-Bodenburg/goi;
    $string =~ s/^Angela Krauß$/Angela Krauss/goi;
    $string =~ s/^Andy Mc Nab$/Andy McNab/goi;
    $string =~ s/^Amery, Carl$/Carl Amery/goi;
    $string =~ s/^Anthony de Mello$/Anthony De Mello/goi;
    $string =~ s/^Anne McCaffrey,$/Anne McCaffrey/goi;
    $string =~ s/^McCaffrey, Anne \& Stirling, S M$/Anne McCaffrey & S. M. Stirling/goi;
    $string =~ s/^McCaffrey, Anne \& Nye, Jody Lynn$/Anne McCaffrey & Jody Lynn Nye/goi;
    $string =~ s/^McCaffrey, Anne \& Lackey, Mercedes$/Anne McCaffrey & Mercedes Lackey/goi;
    $string =~ s/^McCaffrey, Anne \& Ball, Margaret$/Anne McCaffrey & Margaret Ball/goi;
    $string =~ s/^Anne McCaffrey \& Elizabeth Scarborough$/Anne McCaffrey & Elizabeth Ann Scarborough/goi;
    $string =~ s/^Angela Und Karlheinz Steinmueller$/Angela Steinmüller & Karlheinz Steinmüller/goi;
    $string =~ s/^Sjöberg, Arne$/Arne Sjöberg/goi;
    $string =~ s/^C.C. Bergius$/C. C. Bergius/goi;
    $string =~ s/^CC Bergius$/C. C. Bergius/goi;
    $string =~ s/^CH Guenter$/C. H. Guenter/goi;
    $string =~ s/^C.H.Guenter$/C. H. Guenter/goi;
    $string =~ s/^Bukowsky, Charles$/Charles Bukowski/goi;
    $string =~ s/^Adair, Cherry$/Cherry Adair/goi;
    $string =~ s/^Brian W Aldiss$/Brian W. Aldiss/goi;
    $string =~ s/^Brian Aldiss$/Brian W. Aldiss/goi;
    $string =~ s/^Bjoern Larsson$/Björn Larsson/goi;
    $string =~ s/^Bo R Holmberg$/Bo R. Holmberg/goi;
    $string =~ s/^Droste-Hülshoff$/Annette Von Droste-Hülshoff/goi;
    $string =~ s/^Amory, Cleveland$/Cleveland Amory/goi;
    $string =~ s/^Clifford D Simak$/Clifford D. Simak/goi;
    $string =~ s/^C.S.Lewis$/C. S. Lewis/goi;
    $string =~ s/^C.S. Lewis$/C. S. Lewis/goi;
    $string =~ s/^CS Lewis$/C. S. Lewis/goi;
    $string =~ s/^dale brown$/Dale Brown/goi;
    $string =~ s/^Clive Staples Lewis$/C. S. Lewis/goi;
    $string =~ s/^Annette Von Droste Huelshoff$/Annette Von Droste-Hülshoff/goi;
    $string =~ s/^Annik Berte Bratt$/Berte Bratt/goi;
    $string =~ s/^Arkadi und Boris Strugatzki$/Arkadij Strugatzkij & Boris Strugatzkij/goi;
    $string =~ s/^Arkadi Und Boris Strugazki$/Arkadij Strugatzkij & Boris Strugatzkij/goi;
    $string =~ s/^Arkady Und Boris Strugatzki$/Arkadij Strugatzkij & Boris Strugatzkij/goi;
    $string =~ s/^Arne Sjoeberg$/Arne Sjöberg/goi;
    $string =~ s/^Arthur C Clarke Und Stephen Baxter$/Arthur C. Clarke & Stephen Baxter/goi;
    $string =~ s/^McCaffrey, Anne$/Anne McCaffrey/goi;
    $string =~ s/^Anne Mc Caffrey$/Anne McCaffrey/goi;
    $string =~ s/^Ernst Vlcek \/ Neal Davenport$/Ernst Vlcek & Neal Davenport/goi;
    $string =~ s/^Cherryh, C. J.$/C. J. Cherryh/goi;
    $string =~ s/^CJ Cherryh$/C. J. Cherryh/goi;
    $string =~ s/^C.J. Cherryh$/C. J. Cherryh/goi;
    $string =~ s/^Cody Mc Fayden$/Cody McFadyen/goi;
    $string =~ s/^Cody Mc Fadyen$/Cody McFadyen/goi;
    $string =~ s/^Asa Larsson$/Åsa Larsson/goi;
    $string =~ s/^Asa Nilsonne$/Åsa Nilsonne/goi;
    $string =~ s/^Goessling, Andreas$/Andreas Gössling/goi;
    $string =~ s/^Gößling, Andreas$/Andreas Gössling/goi;
    $string =~ s/^Andreas Goessling$/Andreas Gössling/goi;
    $string =~ s/^Lumley, Brian$/Brian Lumley/goi;
    $string =~ s/^Traven, B.$/B. Traven/goi;
    $string =~ s/^B Traven$/B. Traven/goi;
    $string =~ s/^Christine Noestlinger$/Christine Nöstlinger/goi;
    $string =~ s/^Christian von Ditfurth$/Christian Von Ditfurth/goi;
    $string =~ s/^Christian v. Ditfurth$/Christian Von Ditfurth/goi;
    $string =~ s/^Brian Herbert\&Kevin J. Anderson$/Brian Herbert & Kevin J. Anderson/goi;
    $string =~ s/^Herbert, Brian \& Anderson, Kevin J.$/Brian Herbert & Kevin J. Anderson/goi;
    $string =~ s/^Brian Herbert Und Kevin J Anderson$/Brian Herbert & Kevin J. Anderson/goi;
    $string =~ s/^Mull, Brandon$/Brandon Mull/goi;
    $string =~ s/^Crouch, Blake$/Blake Crouch/goi;
    $string =~ s/^Billy Mills\&Nicholas Spark$/Billy Mills & Nicholas Spark/goi;
    $string =~ s/^Fitzhugh, Bill$/Bill Fitzhugh/goi;
    $string =~ s/^Bratt, Berte$/Berte Bratt/goi;
    $string =~ s/^Kellermann, Bernhard$/Bernhard Kellermann/goi;
    $string =~ s/^Hartmann, Bernd$/Bernd hartmann/goi;
    $string =~ s/^CONNERS, Bernard F.$/Bernard F. Conners/goi;
    $string =~ s/^Bova, Ben$/Ben Bova/goi;
    $string =~ s/^Gur, Batya$/Batya Gur/goi;
    $string =~ s/^Barry Longyear Und David Gerrold$/Barry B. Longyear & David Gerrold/goi;
    $string =~ s/^Barry B Longyear$/Barry B. Longyear/goi;
    $string =~ s/^Hambly, Barbara$/Barbara Hambly/goi;
    $string =~ s/^Hacke, Axel \& Sowa, Michael$/Axel Hacke & Michael Sowa/goi;
    $string =~ s/^Lindgren, Astred$/Astrid Lindgren/goi;
    $string =~ s/^Upfield,Arthur W.$/Arthur W. Upfield/goi;
    $string =~ s/^Arthur W Upfield$/Arthur W. Upfield/goi;
    $string =~ s/^Doyle, Conan$/Arthur Conan Doyle/goi;
    $string =~ s/^Arthur C Clarke$/Arthur C. Clarke/goi;
    $string =~ s/^Clarke, Arthur C.$/Arthur C. Clarke/goi;
    $string =~ s/^Bell, Art \& Strieber, Whitley$/Art Bell & Whitley Strieber/goi;
    $string =~ s/^Zitelmann, Arnulf$/Arnulf Zitelmann/goi;
    $string =~ s/^Strugazki, Arkadi \& Boris$/Arkadij Strugatzkij & Boris Strugatzkij/goi;
    $string =~ s/^Saint-Exupery, Antoine de$/Antoine De Saint-Exupéry/goi;
    $string =~ s/^Antoine de Saint-Exupery$/Antoine De Saint-Exupéry/goi;
    $string =~ s/^Antoine de Saint-Exupéry$/Antoine De Saint-Exupéry/goi;
    $string =~ s/^Bello, Antoine$/Antoine Bello/goi;
    $string =~ s/^Blinda, Antje;Orth, Stephan$/Antje Blinda & Stephan Orth/goi;
    $string =~ s/^Horowitz, Anthony$/Anthony Horowitz/goi;
    $string =~ s/^Burgess, Anthony$/Anthony Burgess/goi;
    $string =~ s/^Bratt, Berte$/Berte Bratt/goi;
    $string =~ s/^Reich, Annika$/Annika Reich/goi;
    $string =~ s/^McCaffrey, Anne$/Anne McCaffrey/goi;
    $string =~ s/^Steinhöfel, Andreas$/Andreas Steinhöfel/goi;
    $string =~ s/^Richter, Andreas$/Andreas Richter/goi;
    $string =~ s/^Knuf, Andreas$/Andreas Knuf/goi;
    $string =~ s/^Goessling, Andreas$/Andreas Gössling/goi;
    $string =~ s/^Gößling, Andreas$/Andreas Gössling/goi;
    $string =~ s/^Franz, Andreas$/Andreas Franz/goi;
    $string =~ s/^VÃ¡zquez MontalbÃ¡n, Manuel$/Manuel Vázquez Montalbán/goi;
    $string =~ s/^Vázquez Montalbán, Manuel$/Manuel Vázquez Montalbán/goi;
    $string =~ s/^Vázquez Montalbán$/Manuel Vázquez Montalbán/goi;
    $string =~ s/^Erasmus von Rotterdam$/Erasmus Von Rotterdam/goi;
    $string =~ s/^ERIC FRANK RUSSELL$/Eric Frank Russell/goi;
    $string =~ s/^Eric. L. Harry$/Eric L. Harry/goi;
    $string =~ s/^eric l harry$/Eric L. Harry/goi;
    $string =~ s/^Friesner, Esther$/Esther Friesner/goi;
    $string =~ s/^Eric van Lustbader$/Eric Van Lustbader/goi;
    $string =~ s/^E. T. A.  Hoffmann$/E. T. A. Hoffmann/goi;
    $string =~ s/^E.T.A. Hoffmann$/E. T. A. Hoffmann/goi;
    $string =~ s/^ETA Hoffmann$/E. T. A. Hoffmann/goi;
    $string =~ s/^Forbes, Colin$/Colin Forbes/goi;
    $string =~ s/^Fortier, Anne$/Anne Fortier/goi;
    $string =~ s/^Frederik Pohl\&Jack Williamson$/Frederik Pohl & Jack Williamson/goi;
    $string =~ s/^Freder van Holk$/Freder Van Holk/goi;
    $string =~ s/^fritz fischer$/Fritz Fischer/goi;
    $string =~ s/^Gerrold, David$/David Gerrold/goi;
    $string =~ s/^Grün, Anselm$/Anselm Grün/goi;
    $string =~ s/^Herbert, Brian \/ Anderson, Kevin J.$/Brian Herbert & Kevin J. Anderson/goi;
    $string =~ s/^Herbert, Frank$/Frank Herbert/goi;
    $string =~ s/^Horowitz, Anthony $/Anthony Horowitz/goi;
    $string =~ s/^Huby, Felix$/Felix Huby/goi;
    $string =~ s/^Ibbotson, Eva$/Eva Ibbotson/goi;
    $string =~ s/^Klee, Constanze$/Constanze Klee/goi;
    $string =~ s/^Koehler, Erich$/Erich Köhler/goi;
    $string =~ s/^König, Dieter$/Dieter König/goi;
    $string =~ s/^Link, Charlotte$/Charlotte Link/goi;
    $string =~ s/^Lowell, Elizabeth$/Elizabeth Lowell/goi;
    $string =~ s/^Mcfadyen, Cody$/Cody McFadyen/goi;
    $string =~ s/^McFadyen, Cody$/Cody McFadyen/goi;
    $string =~ s/^McCOULLOUGH, Colleen$/Colleen McCoullough/goi;
    $string =~ s/^Rice, Anne$/Anne Rice/goi;
    $string =~ s/^MARIO PUZO$/Mario Puzo/goi;
    $string =~ s/^Higgins Clark, Mary$/Mary Higgins Clark/goi;
    $string =~ s/^Heitz, Markus$/Markus Heitz/goi;
    $string =~ s/^Mark T Sullivan$/Mark T. Sullivan/goi;
    $string =~ s/^Michalewsky, Nikolai von$/Mark Brandis/goi;
    $string =~ s/^Brandis, Mark$/Mark Brandis/goi;
    $string =~ s/^SIR ARTHUR CONAN DOYLE$/Arthur Conan Doyle/goi;
    $string =~ s/^Sir Arthur Conan Doyle$/Arthur Conan Doyle/goi;
    $string =~ s/^Strugatzkij, Arkadij \& Boris$/Arkadij Strugatzkij & Boris Strugatzkij/goi;
    $string =~ s/^Vlcek, Ernst$/Ernst Vlcek/goi;
    $string =~ s/^Wallace, Edgar$/Edgar Wallace/goi;
    $string =~ s/^Marion Zimmer Bradley, Diana Paxson$/Marion Zimmer Bradley & Diana Paxson/goi;
    $string =~ s/^Bradley, Marion Zimmer$/Marion Zimmer Bradley/goi;
    $string =~ s/^MANFRED BÖCKL$/Manfred Böckl/goi;
    # typical nonsense, App/OS-related
    $string =~ s/^user$//goi;
    $string =~ s/^Unknown$//goi;
    $string =~ s/^unbekannt$//goi;
    $string =~ s/^Free Use$//goi;
    $string =~ s/^AUTHOR$//goi;
    $string =~ s/^Default$//goi;
    $string =~ s/^System$//goi;
    $string =~ s/^Besitzer$//goi;
    $string =~ s/^Administrator$//goi;
    $string =~ s/^Windows User$//goi;
    $string =~ s/^Workstation$//goi;
    $string =~ s/^Windows 9x\/NT\/2000\/XP User$//goi;
    $string =~ s/^Valued Customer$//goi;
    $string =~ s/^MSOffice$//goi;
    $string =~ s/^Ein geehrter Microsoft-Kunde$//goi;
    $string =~ s/^PDFWriters$//goi;
    $string =~ s/^no name$//goi;
    $string =~ s/^name$//goi;
    $string =~ s/^NEW USER$//goi;
    $string =~ s/^Testname$//goi;
    $string =~ s/^Benutzer [0-9]$//goi;
    $string =~ s/^Benutzer$//goi;
    $string =~ s/^winxp$//goi;
    $string =~ s/^Any$//goi;
    $string =~ s/^Admin$//goi;
    $string =~ s/^home$//goi;
    $string =~ s/^ohne$//goi;
    $string =~ s/^no one$//goi;
    $string =~ s/^Standard$//goi;
    $string =~ s/^VT_ADM$//goi;
    $string =~ s/^OEM$//goi;
    $string =~ s/^OEM[0-9]$//goi;
    $string =~ s/^Nobody$//goi;
    $string =~ s/^\*$//goi;
    if ($bicap) {
        $string =~ s/([A-Z])/lc($1)/ge;
        $string =~ s/(\w+)/\u\L$1/g;
    }
    # too short
    $string =~ s/^[0-9]$//goi;
    $string =~ s/^[0-9][0-9]$//goi;
    $string =~ s/^[1-z]$//goi;
    $string =~ s/^[A-z]$//goi;
    $string =~ s/^[A-z][A-z]$//goi;
    # typical prefixes
    $string =~ s/^Roman: //goi;
    $string =~ s/^\(c\) //goi;
    # spaces, dots and such
    $string =~ s/^\.+//goi;
    $string =~ s/^ - //goi;
    $string =~ s/^- //goi;
    $string =~ s/^-//goi;
    $string =~ s/^ //goi;
    $string =~ s/ $//goi;
    if ($debug) { print (stderr " string-out: '$string'\n"); };
    return $string; 
}

sub regex_title {
    my $string = $_[0];
    if ($debug) { print (stderr " string-in : '$string'\n"); };
    $string =~ s/^Untitled$//goi;
    $string =~ s/^TITLE$//goi;
    $string =~ s/^Default$//goi;
    $string =~ s/^\(Microsoft Word - //goi;
    $string =~ s/^Microsoft Word - //goi;
    $string =~ s/^Microsoft Word$//goi;
    $string =~ s/^Microsoft PowerPoint - //goi;
    $string =~ s/^Microsoft PowerPoint$//goi;
    $string =~ s/^Word Pro - //goi;
    $string =~ s/^eBook$//goi;
    $string =~ s/^FreePDF, Job [0-9]$//goi;
    $string =~ s/^Cover$//goi;
    $string =~ s/^Deckblatt$//goi;
    $string =~ s/^vorlage$//goi;
    $string =~ s/^Unbenannt$//goi;
    $string =~ s/^titel$//goi;
    $string =~ s/^Bildern$//goi;
    $string =~ s/^aaaa$//goi;
    $string =~ s/^fantasy1$//goi;
    $string =~ s/^band[0-9]$//goi;
    $string =~ s/^band[0-9][0-9]$//goi;
    $string =~ s/^DKG3$//goi;
    $string =~ s/^B\\374ffel$//goi;
    $string =~ s/^\&\#x01\;$//goi;
    $string =~ s/^602Text$//goi;
    $string =~ s/^print job$//goi;
    $string =~ s/^DANKSAGUNG$//goi;
    $string =~ s/^EINLEITUNG$//goi;
    $string =~ s/^PROLOGUE$//goi;
    $string =~ s/^Prolog$//goi;
    $string =~ s/^Vorwort$//goi;
    $string =~ s/^Layout 1$//goi;
    $string =~ s/^Materialien-Deckel$//goi;
    $string =~ s/^Dokument1$//goi;
    $string =~ s/^Grafik1$//goi;
    $string =~ s/^grafik[0-9]$//goi;
    $string =~ s/^grafik [0-9]$//goi;
    $string =~ s/^Untitled1$//goi;
    $string =~ s/^Namenlos-2$//goi;
    $string =~ s/^MZB-1st-k$//goi;
    $string =~ s/^buch$//goi;
    $string =~ s/Impresión de fax de página completa//goi;
    $string =~ s/^1$//goi;
    $string =~ s/^01$//goi;
    $string =~ s/^x$//goi;
    $string =~ s/cover-image-large.jpg//goi;
    $string =~ s/\.pdf$//goi;
    $string =~ s/-pdf$//goi;
    $string =~ s/\.doc$//goi;
    $string =~ s/\.doc\)$//goi;
    $string =~ s/\.html$//goi;
    $string =~ s/\.htm$//goi;
    $string =~ s/\.sdw$//goi;
    $string =~ s/\.dvi$//goi;
    $string =~ s/\.qxd$//goi;
    $string =~ s/\.ppt$//goi;
    $string =~ s/\.cdr$//goi;
    $string =~ s/\.rtf$//goi;
    $string =~ s/\.indd$//goi;
    $string =~ s/^file:\/\/.*//goi;
    $string =~ s/^[A-z]:\\.*//goi;
    $string =~ s/^[a-z][a-z]$//goi;
    $string =~ s/\<DDT\>//goi;
    $string =~ s/\<STD\>//goi;
    $string =~ s/\(Scan, OCR\)//goi;
    $string =~ s/\(Scan, No OCR\)//goi;
    $string =~ s/\(No OCR\)//goi;
    $string =~ s/\(OCR\)//goi;
    $string =~ s/\(ATTiCA\)//goi;
    $string =~ s/\(MOGUL Edition\)//goi;
    $string =~ s/^Inhalt$//goi;
    $string =~ s/^inha$//goi;
    $string =~ s/^Index$//goi;
    $string =~ s/^Hallo$//goi;
    # if this is set replace the name with its lowercase version.
    if ($bicap) {
        $string =~ s/([A-Z])/lc($1)/ge;
        $string =~ s/(\w+)/\u\L$1/g;
    }
    $string =~ s/^\.+//goi;
    $string =~ s/^ - //goi;
    $string =~ s/^- //goi;
    $string =~ s/^-//goi;
    $string =~ s/^ //goi;
    $string =~ s/ $//goi;
    if ($debug) { print (stderr " string-out: '$string'\n"); };
    return $string; 
}

opendir(my $in_dir, $dname) || die "I am unable to access that directory...Sorry";
my @dir_contents = readdir($in_dir);
closedir($in_dir);

@dir_contents = sort(@dir_contents);

my $wddir = getcwd;
if ($dname ne ".") {
    $wddir = $wddir . "/" . $dname;
}
my $base = basename($wddir);
my $baseauthor;

# FIXME: directory not the current one, or one specified with "..". 
print "$base\n";
# if the Directory-name is in CamelCase, assume it's the author
if ($base =~ /[[:upper:]](?:[[:upper:]]+|[[:lower:]]*)(?=$|[:upper:])/) {
    for ($base) {
        my @baseparts = /[[:upper:]](?:[[:upper:]]+|[[:lower:]]*)(?=$|[[:upper:]])/g;
        # print "$_ => @baseparts\n";
        $baseauthor = join(" ",@baseparts);
# FIXME: treatment: "Und" and "And" plus lone-standing initials.
    }
}


# if the File-name is CamelCase too, assume it's the title
foreach my $file (@dir_contents) {
    my $title="";
    my $author="";
    my $publisher;
    my $date;
    my $isbn;

    if (-f $file) {

        print "filename : $file\n";
        # my $suffix = (fileparse($file,'\.[^.]*'))[2];

        my $name = $file;
        my $suffix;
        ($name,$suffix) = $name =~ /^(.*)(\.[^.]*)$/;

        # Does Title contain isbn?
        if ($name =~ m/(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?([0-9xX])/) {
            # match above works, extraction below fails:
            ($isbn) = /(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?(\d)[- ]?([0-9xX])/;
            print "isbn: $isbn\n";
        };

        if (($name =~ /[[:upper:]0-9](?:[[:upper:]-0-9]+|[[:lower:]-0-9]*)(?=$|[[:upper:]-0-9])/) && ! ($name =~ /[\s_]/) ) {
            for ($name) {
                my @parts = /[[:upper:]-0-9](?:[[:upper:]-0-9]+|[[:lower:]-0-9]*)(?=$|[[:upper:]-0-9])/g;
                $title = join(" ",@parts);
            }
        # fix adjacent slashes
        $title =~ s/- / - /g;
        $title =  cleanex($title);
        }

        if (($author ne "") && ($title ne "")) {
            print "from-nam1: $author ¤ $title\n"; 
        } elsif (($title ne "") && ($baseauthor ne "")) {
            $author = $baseauthor;
            print "from-nam1: $author ¤ $title\n"; 
        } elsif ($title ne "") {
            print "from-nam1: $title\n"; 
        }

# FIXME: Authors with comma or ";" separated
# FIXME: Authors with last-comma-first

        $_ = $name; 
        # print "file-excl:   $name\n";
        if ($_ =~ m/(.+)\-(.+)\((.+)\,(.+)\)[ W]?/) {
            ($title, $author, $publisher, $date) = /(.+)\-(.+)\((.+)\,(.+)\)[ W]?/;
            if ($title eq "") {
                $_ = $name;
                ($title, $publisher, $date) = /(.+)\((.+)\,(.+)\)/;
            }
            if ($date eq "") {
                $_ = $name;
                ($title, $publisher) = /(.+)\((.+)\)/;
            }
            $author = cleanex($author);
            $title =  cleanex($title);
            $publisher = cleanex($publisher);
                $date = cleanex($date);
            print "from-nam2: $author ¤ $title\n";
        }

        # those need to be forced
        if ($f_authortitle && ! $f_titleauthor) {
            if ($name =~ m/(.*?) - (.*)/) {
                ($author, $title) = /(.*?) - (.*)/;
                $title =  cleanex($title);
                # those need to be forced
                if ($f_prefix) {
                    # usually this comes from calibre, so:
                    $title =~ s/_ /: /goi;
                    if ($title =~ m/(.*), The$/) {
                    $title =~ s/, The$//goi;
                    $title = "The ". $title;
                    }
                    if ($title =~ m/(.*), A$/) {
                    $title =~ s/, A$//goi;
                    $title = "A ". $title;
                    }
                    if ($title =~ m/(.*), An$/) {
                    $title =~ s/, An$//goi;
                    $title = "An ". $title;
                    }
                }
                $author = cleanex($author);
                print "from-nam3: $author ¤ $title\n";
            }
        }

        # those need to be forced
        if ($f_titleauthor && ! $f_authortitle) {
            if ($name =~ m/(.*) - (.*)/) {
                ($title, $author) = /(.*) - (.*)/;
                $title =  cleanex($title);
                $author = cleanex($author);
                print "from-nam4: $author ¤ $title\n";
            }
        }

        # those need to be forced
        if ($f_title) {
            if ($_ =~ m/(.+)\ \((.+)\)/) {
                ($title, $date) = /(.*) \((.*)\)/;
                $date =  cleanex($date);
            } else {
                ($title) = /(.*)/;
            }
            $title =  cleanex($title);
            print "from-nam5: $title ¤ $date\n";
        }


        if ($fixpdf) {
        my $newfile = $name . 2 . $suffix; 
        my $tempmeta = $name . 2 . ".meta"; 
            system ("pdftk \"$file\" dump_data output \"$tempmeta\" uncompress");
            system ("pdftk \"$file\" update_info \"$tempmeta\" output \"$newfile\"");
            rename ("$newfile", "$file");
            unlink ("$tempmeta");
        }

        my $exifTool = new Image::ExifTool;
        my $info = $exifTool->ImageInfo($file);

        print "from-meta: ";


        if ($forcetitle) {
            if ($author ne "") {
                    $exifTool->SetNewValue(Title => $author);
                print "$author ¤ ";
            }
        }
        if ($$info{'Author'}  && ! $forcetitle) {
            if ($$info{'Author'} eq regex_author($$info{'Author'})) {
                    print "$$info{'Author'} ¤ "; 
            } else {
                    $exifTool->SetNewValue(Author => regex_author($$info{'Author'}));
            }
        } else {
                $exifTool->SetNewValue(Author => $author);
        }

        if ($forcetitle) {
            if ($title ne "") {
                print "forectitle: $title ";
                    $exifTool->SetNewValue(Title => $title);
            }
        }
        if ($$info{'Title'} && ! $forcetitle) {
            if ($$info{'Title'} eq regex_title($$info{'Title'})) {
                    print "$$info{'Title'} "; 
            } else {
                    $exifTool->SetNewValue(Title => regex_title($$info{'Title'}));
                    print "" . regex_title($$info{'Title'}); 
            }
        } else {
                $exifTool->SetNewValue(Title => $title);
        }

        if ($$info{'ISBN'}) {
                print "¤ $$info{'ISBN'} "; 
        } else {
                $exifTool->SetNewValue(ISBN => $isbn);
        }
        if ($$info{'Publisher'}) {
                print "¤ $$info{'Publisher'} "; 
        } else {
                $exifTool->SetNewValue(Publisher => $publisher);
        }
        if ($$info{'Date'}) {
            print "$$info{'Date'} "; 
        } else { 
                $exifTool->SetNewValue(Date => $date);
        }

        print "\n\n";

        if ($write) {
            $exifTool->Options(IgnoreMinorErrors => 1);
                $exifTool->WriteInfo($file);
            if (my $error = $exifTool->GetValue('Error')) {
                print "$error\n";
            }
        }
    }
}

__END__

=head1 NAME

exif-meta - set exif information from filename. Right now, 
    expects filename either BiCapitalized or in format 
    title - author (publisher, date)

=head1 SYNOPSIS

B<This program> [options] [files ...]

 Options:
   -h|--help
   -f|--force
   --fix
   -w|--write
   -a|format-authorttitle
   -x|format-titleauthor
   -t|format-title
   -p|format-prefix
   -b|bicap

=head1 OPTIONS

=over 8

=item B<-h|--help>

Print a brief help message and exit.

=item B<-f|--force>

Force writing of title- and author-tag (from filename), even if 
a respective exif-tag already exists.

=item B<--fix>

cat the whole document trough pdftk. Fixes missing permissions,
user passwords and other small defects. Since 0.6 also preserves
metadata (means: it does not try to set them from the filename).

=item B<-w|--write>

Really writes tags, not only display them. 

=item B<-a|format-authorttitle>

Format is "author - title". Force this. 

=item B<-x|format-titleauthor>

Format is "title - author". Force this. 

=item B<-t|format-title>

Format is just "title". Force this. 

=item B<-p|format-prefix>

Fix sort-order prefix which has been appended to the end. One looks like
Yoda talks, The. 

=item B<-b|bicap>

first lowercase and then bicapitalize author/title.

=back

=head1 DESCRIPTION

B<This program> does something

=cut
