#!/usr/bin/perl -w
use strict;
use SVG;

# test: getFirstChild, getLastChild, getParent, getChildren

my $svg=new SVG;
my $parent=$svg->group();
my $child1=$parent->text->cdata("I am the first child");
my $child2=$parent->text->cdata("I am the second child");

print ("Failed on hasSiblings") and exit(0)
	unless $child1->hasSiblings();
print ("Failed on getNextSibling") and exit(0)
	if $child1->getNextSibling() != $child2;
print ("Failed on getPreviousSibling") and exit(0)
	if $child2->getPreviousSibling() != $child1;

exit 1;
