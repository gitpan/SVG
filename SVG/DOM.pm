=pod 

=head1 NAME

SVG::DOM - Perform DOM (Document object model) manipulations of the SVG object.

=head1 SUMMARY

An API for accessing the SVG DOM.

=head1 AUTHOR

Ronan Oger, ronan@roasp.com

=head1 SEE ALSO

perl(1),L<SVG>,L<SVG::XML>,L<SVG::Element>,L<SVG::Parser>, L<SVG::Manual>
http://www.roasp.com/
http://www.perlsvg.com/
http://www.roitsystems.com/
http://www.w3c.org/Graphics/SVG/

=cut

package SVG::DOM;

$VERSION = "0.21";

use strict;

use vars qw($VERSION @ISA @EXPORT );

require Exporter;

@ISA = qw(Exporter);

@EXPORT = qw(
  getChildren
  getFirstChild
  getLastChild
  getParent
  getSiblings
  getElementByID
  getElementID
  getElements
  getElementName
  getParentElement
  getType
  getAttributes
  getAttribute
);

# Methods

=pod

=head1 Warning: This module is still in development and is subject to change.

=head2 Methods

 To pe provided:  $ref = $svg->getElementByID($id) 

Return the reference to the element which has id $id

 $ref = $svg->getFirstChild() 

return the reference of the first defined child of the current node

 $ref = $svg->getLastChild() 

return the array of references of the last defined child of the current node

 @array_of_Refs =  $svg->getChildren()

return the reference of the children of the current node

 $ref = $svg->getParent()

return the reference of the parent of the current node
  
 $ref = $svg->getSiblings()
  
return the reference to an array composed of references of the siblings of the current node

getElementName
  
 $val = $svg->getElementName()

return a string containing the element type of a reference to an node
  
$ref = $ref->getAttributes()

return a reference to a hash whose keys are the attribute name and the values are the attribute values.

$ref = $ref->getAttribute('attributeName')

return a string with the value of the attribute. $ref is the reference to the element that contains the attribute 'attributeName'.

 To pe provided: $ref = getCDATA ($ref) 

=cut

#Methods
#-----------------
# sub GetFirstChild
sub getFirstChild ($) {
	my $self = shift;
	return $self->getChildren()->[0];
}

#-----------------
# sub GetLastChild

sub getLastChild ($) {
	my $self = shift;
	return $self->getChildren()->[-1];
}

#-----------------
# sub getChildren

sub getChildren ($) {
	my $self = shift;
	return $self->{-childs};
}

#-----------------
# sub getParent
# return the ref of the parent of the current node

sub getParent {
	my $self = shift;
	return $self->{-parent};
}

sub getSiblings {
	my $self = shift;
	my $par = $self->getParent();
	return $par->getChildren();
}

sub getElementName ($) {
	my $self = shift;
	return $self->{-name};
}


sub getElements ($$) {
	my $self = shift;
	my $element = shift;
	return $self->{-docref}->{-elist}->{$element};
}

sub getElementID ($) {
	my $self = shift;
	return $self->{id};
}

sub getElementByID ($$) {
	my $self = shift;
	my $id = shift;
	return $self->{-docref}->{-idlist}->{$id};
}
*getElementbyID=\&getElementByID;
*getType=\&getElementName;

sub getAttributes ($) {
	my $self = shift;
	my $out = {};
	foreach my $i (keys %$self) {
		$out->{$i} = $self->{$i} unless $i =~ /^-/;
	}
	return $out;
}

sub getAttribute ($$) {
	my $self = shift;
	my $attr = shift;
	return $self->{$attr};
}

#-------------------------------------------------------------------------------

1;

