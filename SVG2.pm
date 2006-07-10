package SVG2;

=pod 

=head1 NAME

SVG2 - SVG extention to the popular XML2

=head2 VERSION

Version 1.00, 08 May, 2006

=head1 DESCRIPTION

An SVG Extention of XML2, this should provide for all features of the svg specification upto 1.1.

=head1 METHODS

=cut

use strict;
use vars qw($VERSION);

use base "XML2";
use Carp;

# Basic Element Types
use SVG2::Element::Rect;
use SVG2::Element::Text;
use SVG2::Element::Path;
use SVG2::Element::Group;
use SVG2::Element::Line;
use SVG2::Element::Document;

$VERSION = "1.00";

=head2 new

$svg = SVG2->new(
	-file = [svgfilename],
	-data = [svgdata],
	%options
);

Create a new svg object, it will parse a file or data if required or will await creation of nodes.

=cut
sub new
{
    my ($proto, %options) = @_;
    return $proto->SUPER::new(%options);
}

=head2 _element_handle

This is the XML2 handel for all the elements that
svg documents can handle.

=cut
sub _element_handle
{
	my ($self, $type, %opts) = @_;
	return SVG2::Element::Rect->new(%opts) if $type eq 'rect';
	return SVG2::Element::Text->new(%opts) if $type eq 'text' or $type eq 'tspan';
	return SVG2::Element::Path->new(%opts) if $type eq 'path';
	return SVG2::Element::Group->new(%opts) if $type eq 'g';
	return SVG2::Element::Line->new(%opts) if $type eq 'line';
	if($type eq '#document' or $type eq 'svg') {
		$opts{'documentTag'} = $type if $type ne '#document';
		return SVG2::Element::Document->new(%opts);
	}
	return $self->SUPER::_element_handle($type, %opts);
}

sub _document_name { 'svg' }
sub default_unit { 'px' }

sub dpi
{
	my ($self) = @_;
	return $self->{'dpi'} || '90';
}

sub out_dpi
{
	my ($self) = @_;
	return $self->{'out_dpi'} || $self->dpi;
}

=head1 AUTHOR

Martin Owens, doctormo@cpan.org

=head1 SEE ALSO

perl(1),L<XML2>,L<XML2::Parser>
L<http://www.w3c.org/Graphics/SVG/> SVG at the W3C

=cut 

return 1;
