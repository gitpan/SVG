#!/usr/bin/perl -w
use strict;
use SVG;

my $svg=new SVG;
exit 0 unless $svg;
my $tag=$svg->circle();
exit 0 unless $tag;

exit 1;

