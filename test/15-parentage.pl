#!/usr/bin/perl -w
use strict;
use SVG;

# test: getFirstChild, getLastChild, getParent, getChildren

my $svg=new SVG;
my $parent=$svg->group();
my $child1=$parent->text->cdata("I am the first child");
my $child2=$parent->text->cdata("I am the second child");

print ("Failed on getFirstChild") and exit(0)
	if $parent->getFirstChild() != $child1;
print ("Failed on getParent 1") and exit(0)
	if $child1->getParent() != $parent;
print ("Failed on getLastChild") and exit(0)
	if $parent->getLastChild() != $child2;
print ("Failed on getParent 2") and exit(0)
	if $child2->getParent() != $parent;
print ("Failed on hasChildren") and exit(0)
	unless $parent->hasChildren();
my @children=$parent->getChildren();
print ("Wrong number of children") and exit(0)
	if scalar(@children) != 2;
print ("Failed on getChildren 1") and exit(0)
	if $children[0] != $child1;
print ("Failed on getChildren 2") and exit(0)
	if $children[1] != $child2;

exit 1;
