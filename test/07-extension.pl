#!/usr/bin/perl -w
use strict;
use SVG;

my $svg=new SVG(-extension => "<!ENTITY % myentity \"myvalue\">");
$svg->group->text->cdata("Extensions");
my $xml=$svg->render;

print("Failed in extension: $xml") and exit(0)
    unless $xml=~/[\n<!ENTITY % myentity "myvalue">\n]>/;

exit 1;
