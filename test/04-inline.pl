#!/usr/bin/perl -w
use strict;
use SVG qw(-inline 1);

# test: -inline

my $svg1=new SVG();
$svg1->text->cdata("An inline document");
my $xml1a=$svg1->render();
exit 0 if $xml1a=~/DOCTYPE/;
my $xml1b=$svg1->render(-inline => 0);
exit 0 if $xml1b!~/DOCTYPE/;

my $svg2=new SVG(-inline => 0);
my $xml2a=$svg2->render();
exit 0 if $xml2a!~/DOCTYPE/;
my $xml2b=$svg2->render(-inline => 1);
exit 0 if $xml2b=~/DOCTYPE/;

exit 1;
