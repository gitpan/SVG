#!/usr/bin/perl -w
use strict;
use SVG (-indent => '*', -elsep => '|', -nocredits => 1);

# test: -indent -elsep -nocredits

my $svg=new SVG();
$svg->group->text->cdata("Look and Feel");
my $xml=$svg->render();
print("Failed in elsep") and exit(0)
    if $xml=~/\n/ or not $xml=~/\|/;
print("Failed in indent") and exit(0)
    unless $xml=~/\*\*/;

exit 1;
