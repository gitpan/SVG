#!/usr/bin/perl -w
use strict;
use SVG;

# test: getElementTypes, getElementsByType, getElementType, getElementsByType, getElementTypes

my $svg=new SVG;
my $parent=$svg->group();
my $child1=$parent->text->cdata("I am the first child");
my $child2=$parent->text->cdata("I am the second child");

print ("Failed on getElementType") and exit(0)
	unless $child1->getElementType() eq "text";
print ("Failed on getElementsByType 1") and exit(0)
	unless scalar(@{$svg->getElementsByType("g")})==1;
print ("Failed on getElementsByType 2") and exit(0)
	unless scalar(@{$svg->getElementsByType("text")})==2;
print ("Failed on getElementsTypes") and exit(0)
	unless scalar(@{$svg->getElementTypes()})==3;

exit 1;
