#!/usr/bin/perl -w
use strict;
use SVG;

my $svg=new SVG();
my $group=$svg->group(id=>'the_group');

print("Failed on getElementID") and exit(0)
	unless $group->getElementID() eq "the_group";
print("Failed on getElementByID") and exit(0)
	unless $svg->getElementByID("the_group") == $group;

exit 1;
