#!/usr/bin/perl -w
use strict;
use SVG;

# test: style

my $svg  = new SVG;
my $out1 = $svg->text()->cdata_noxmlesc(SVG::xmlescp("><!&"));
my $out2 = $svg->text()->cdata("><!&");

$svg->xmlify();

print("Failed on xmlesc helper function in svg: 1") and exit(0)
  unless $out1->xmlify() eq $out2->xmlify();

exit 1;
