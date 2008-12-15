#!/usr/bin/perl -w
use strict;
use SVG;

# test: style

my $svg=new SVG;
my $defs = $svg->defs();
my $out;
# a five-sided polygon
my $xv = [0,2,4,5,1];
my $yv = [0,0,2,7,5];

my $points = $svg->get_path(
        x=>$xv, y=>$yv,
        -type=>'polygon'
    );

my $c = $svg->polygon(
        %$points,
        id=>'pgon1',
        style=>{fill=>'red',stroke=>'green'},
	opacity=>0.6,
);

print ("Failed on polygon 1: define") and exit(0) unless
	$c;

$out = $svg->xmlify();

print ("Failed on polygon 2: serialize") and exit(0) unless
	$out =~ /polygon/;

print ("Failed on polygon 3: inline css style") and exit(0) unless
	$out =~ /style/;

print ("Failed on polygon 4: inline css style") and exit(0) unless
	$out =~ /opacity/;

exit 1;
