#!/usr/bin/perl -w


#!/usr/bin/perl -w
use strict;
use SVG ();

# test: -sysid -pubid -docroot

my $svg=new SVG();
my $xml;

$svg->text->cdata("Document type declaration test");
$xml=$svg->dtddecl();

print("Failed on docroot 1: $xml") and exit(0)
	unless $xml=~/DOCTYPE svg /;
print("Failed on pubid 1: $xml") and exit(0)
	unless $xml=~/ PUBLIC "-\/\/W3C\/\/DTD SVG 1.0\/\/EN" /;
print("Failed on sysid 1: $xml") and exit(0)
	unless $xml=~/ "http:\/\/www.w3.org\/TR\/2001\/REC-SVG-20010904\/DTD\/svg10.dtd">/;

$svg=new SVG(-docroot => "mysvg");
$xml=$svg->dtddecl();
print("Failed on docroot 2: $xml") and exit(0)
	unless $xml=~/DOCTYPE mysvg /;

$svg=new SVG(-pubid => "-//ROIT Systems/DTD MyCustomDTD 1.0//EN");
$xml=$svg->dtddecl();
print("Failed on pubid 2: $xml") and exit(0)
	unless $xml=~/ PUBLIC "-\/\/ROIT Systems\/DTD MyCustomDTD 1\.0\/\/EN" /;

$svg=new SVG(-pubid => undef);
$xml=$svg->dtddecl();
print("Failed on pubid 3: $xml") and exit(0)
	unless $xml=~/ SYSTEM "http:\/\/www.w3.org\/TR\/2001\/REC-SVG-20010904\/DTD\/svg10.dtd">/;

$svg=new SVG(-sysid => "http://www.perlsvg.com/svg/my_custom_svg10.dtd");
$xml=$svg->dtddecl();
print("Failed on sysid 2: $xml") and exit(0)
	unless $xml=~/ "http:\/\/www\.perlsvg\.com\/svg\/my_custom_svg10.dtd">/;

exit 1;
