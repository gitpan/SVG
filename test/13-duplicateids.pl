#!/usr/bin/perl -w
use strict;
use SVG;

# test: duplicate ids, -raiserror

my $svga=new SVG();
my $dupnotdetected=eval {
    $svga->group(id=>'the_group');
    $svga->group(id=>'the_group');
    1;
};
print("Failed in raiserror") and exit(0)
    if $dupnotdetected;

my $svgb=new SVG(-raiseerror => 0, -printerror => 0);
$svgb->group(id=>'the_group');
$svgb->group(id=>'the_group');
my $xml=$svgb->render();
print("Failed in error attribute") and exit(0)
    unless $xml=~/errors=/;

exit 1;
