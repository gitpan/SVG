use Test::More tests=>9;
use strict;
use SVG;
# test: getFirstChild, getLastChild, getParent, getChildren

my $svg    = new SVG;
my $parent = $svg->group();
my $child1 = $parent->text->cdata("I am the first child");
my $child2 = $parent->text->cdata("I am the second child");
my $child3 = $parent->text->cdata("I am the third child");

  ok($parent->getFirstChild() == $child1,"getFirstChild");
  ok($child1->getParent() == $parent,"getParent 1");
  ok($parent->getLastChild() == $child3,"getLastChild");
  ok($child2->getParent() == $parent,"getParent 2");
  ok($parent->hasChildren(),"hasChildren");
my @children = $parent->getChildren();
  ok(scalar(@children) == 3,"correct number of children");
  ok($children[0] == $child1,"getChildren 1");
  ok($children[1] == $child2,"getChildren 2");
  ok($children[2] == $child3,"getChildren 3");
