#!/usr/bin/perl

print "Hello, World...\n";

use SVG;

my $s = SVG->new(width=>100,height=>50);
my $g1 = $s->group();
my $g2 = $s->group();
$g1->circle(width=>1,height=>1,id=>'test_id');
$g1->rect(id=>'id_2');
$g1->rect(id=>'id_3');
$g1->rect(id=>'id_4',x=>15,y=>150);
$g1->anchor(-xref=>'http://www.roasp.com/tutorial/',id=>'anchor_1')
	->text(id=>'text_1',x=>15,y=>150,stroke=>'red')->cdata('Hello, World');
$g2->ellipse(id=>'id_5');
$g2->ellipse(id=>'id_6');
$g2->ellipse(id=>'id_7');
$s->ellipse(id=>'id_8');
$s->ellipse(id=>'id_9');

print "I am an SVG document.\n";
print "Here is my XML markup:\n----\n";
print $s->xmlify();

#
# Test of getElementName
#
print "\n\n\nI am actually an element of type ".$s->getElementName()."\n\n\n";
print "-----------------\n","Let's take a look at my attributes\n";

#
# Test of getAttributes
#
show_attributes($s);

print "Let's take a look at the getElement support...";
#
# Test of getElements
#
my @e_names = qw/rect ellipse a g svg/;

foreach my $e_name (@e_names) {

	print "\n\n\nThere are ".scalar @{$s->getElements($e_name)}." '$e_name' elements\n";
	print "\nThis is what they render as using xmlify:\n";

	foreach my $e (@{$s->getElements($e_name)}) {
		my $e_id = $e->getElementID() || '0';
		print "$e -->".$e->xmlify()."\n has id ".$e_id."\nwhich returns handle  -->\n".$s->getElementByID($e_id)."\n
		which renders as: -->\n";
		if ($s->getElementByID($e_id)) {
			print $s->getElementByID($e_id)->xmlify();
		} else {
			print "\n\nOops, I'm afraid that ".$s->getElementByID($e_id)." does not exist with element id '$e_id'\n\n";
			print "That is because this element has no id. You will notice that \$s->getElementByID(\$e_id) is zero because there is no\n";
		}
		print "\n\n------------------\n";
	}

}

print "-----------------\n","Let's get back to me and take a look at my attributes\n";

print "\n-----------------\n","\n\nDo I have any child elements?\n";

my $kids = $s->getChildren();

print "Look at that, I have  ",scalar (@$kids)," child (\$n should be 1)\n";
#foreach my $v (@$kids) {print $kids->[$v]->xmlify()."\n\n";}

foreach my $v (@$kids) {print "Element name = ",$v->getElementName(),"\n\n";show_attributes($v);}

#
# Test of getChildren
#
my $childs = $g1->getChildren();
my $n = scalar (@$childs) -1 ;
my @a = (0..$n);
foreach my $v (@a) {
	print $childs->[$v]->xmlify();
	#
	# Test of getParent
	#
	my $parent = $childs->[$v]->getParent();
	print "its parent contains\n".$parent->xmlify();

	#
	# Test of getElementName on the parent
	#
	my $name = $parent->getElementName;
	print "the parent is an <".$name."></$name> element and";
	#
	# Test of getElementName on itself
	#
	my $name = $childs->[$v]->getElementName;
	print "the child element is an <".$name."></$name> element\n\n";

	#
	# Test of getAttributes
	#
	my $ref = $childs->[$v]->getAttributes();
	my @attrs = keys %$ref;
	print "The child has " . scalar @attrs . " attributes:\n";
	foreach my $i (@attrs) {
		print "attribute = $i value = $ref->{$i}\n";
	}

	print "\n---------------\n";
}

#
# print out the attributes list
#
sub show_attributes ($) {
	$node = shift;
	my $ref = $node->getAttributes();
	my @attrs = keys %$ref;
	print "I have " . scalar @keys . " attributes:\n";
	foreach my $i (@attrs) {
		print "attribute='$i' value='$ref->{$i}'\n";
	}
}