#!/usr/bin/perl -w
use strict;
use SVG;

my $svg=new SVG;
exit 0 unless $svg;
$svg->circle();
my $output=$svg->render();
exit 0 unless $output and length($output);

exit 1;

