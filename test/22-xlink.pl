#!/usr/bin/perl -w
use strict;
use SVG;

# test: style

my $svg  = new SVG;
my $defs = $svg->defs();
my $out;

$out = $svg->xmlify();

print("Failed on xlink definition in svg: 1") and exit(0)
  unless $out =~ /xmlns:xlink=\"http:\/\/www.w3.org\/1999\/xlink"/;

print("Failed on xmlns definition in svg: 2") and exit(0)
  unless $out =~ /xmlns=\"http:\/\/www.w3.org\/2000\/svg"/;

exit 1;
