#!/usr/bin/perl -w
use strict;
use SVG;

my $svg=new SVG();
my $g=$svg->group(fill=>"white", stroke=>"black");

my $fill=$g->attribute("fill");
print("Failed in attribute (get)") and exit(0)
    unless $fill eq "white";

$g->attribute(stroke => "red");
my $stroke=$g->attribute("stroke");
print("Failed in attribute (set)") and exit(0)
    unless $stroke eq "red";

$g->attribute(fill => undef);
print("Failed in attribute (delete)") and exit(0)
    if $g->attribute("fill");

exit 1;
