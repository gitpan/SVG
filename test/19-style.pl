#!/usr/bin/perl -w
use strict;
use SVG;

# test: style

my $svg=new SVG;
my $defs = $svg->defs();
my $rect = $svg->rect(x=>10,y=>10,
	width=>10,height=>10,
	style=>{fill=>'red',stroke=>'green'});
my $out = $svg->xmlify;
print ("Failed on style 1: inline css defs") and exit(0) unless $out =~ /stroke\s*\:\s*green/;

exit 1;
