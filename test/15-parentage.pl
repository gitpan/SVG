#!/usr/bin/perl -w
use strict;
use SVG;
# test: getFirstChild, getLastChild, getParent, getChildren

my $svg    = new SVG;
my $parent = $svg->group();
my $child1 = $parent->text->cdata("I am the first child");
my $child2 = $parent->text->cdata("I am the second child");
my $child3 = $parent->text->cdata("I am the third child");

print("Failed on getFirstChild: 1") and exit(0)
  if $parent->getFirstChild() != $child1;
print("Failed on getParent 1: 2") and exit(0)
  if $child1->getParent() != $parent;
print("Failed on getLastChild: 3") and exit(0)
  if $parent->getLastChild() != $child3;
print("Failed on getParent 2:4 ") and exit(0)
  if $child2->getParent() != $parent;
print("Failed on hasChildren: 5") and exit(0)
  unless $parent->hasChildren();
my @children = $parent->getChildren();
print("Wrong number of children: 6") and exit(0)
  if scalar(@children) != 3;
print("Failed on getChildren 1: 7") and exit(0)
  if $children[0] != $child1;
print("Failed on getChildren 2: 8") and exit(0)
  if $children[1] != $child2;
print("Failed on getChildren 3: 8") and exit(0)
  if $children[2] != $child3;

exit 1;
