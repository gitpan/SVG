=pod 

=head1 NAME

SVG::DOM - Perform DOM manipulations of the SVG object

=head1 SUMMARY

An API for accessing the SVG DOM.

=head1 AUTHOR

Ronan Oger, ronan@roasp.com

=head1 SEE ALSO

perl(1),L<SVG>,L<SVG::XML>,L<SVG::Element>,L<SVG::Parser>, L<SVG::Manual>
http://roasp.com/
http://www.w3c.org/Graphics/SVG/

=cut

package SVG::DOM;

$VERSION = "0.1";

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
  getElementbyID
  getElement
  getType
  getAttribute
);

# Methods
=pod

=head2 Methods

getFirstChild ($ref) 

return the reference of the first defined child of the current node

getLastChild ($ref) 

return the reference of the last defined child of the current node

getChildren ($ref)

return the reference of the children of the current node

getParent ($ref)

return the reference of the parent of the current node
  
getSiblings ($ref)
  
return the reference to an array composed of references of the siblings of the current node

getElementbyID
  
getElement ($ref)

return a string containing the element type of a reference to an node
  
$ref = getAttributes ($ref)

return a reference to a hash whose keys are the attribute name and the values are the attribute values.

$ref = getCDATA ($ref)

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
	return [$self->{-childs}];

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
	$par->getChildren();

}

sub getElement ($) {

}

sub getElementbyID () {

}

sub getType  () {

}

sub getAttributes ($) {
	my $self = shift;
	return $self->{-parent};
}

#-------------------------------------------------------------------------------

1;

