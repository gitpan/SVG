package SVG2::Element::Definition::linearGradient::Stop;

use base "SVG2::Element::Style";

use strict;
use warnings;

sub new
{
    my ($proto, %args) = @_;
    my $self = $proto->SUPER::new('linearGradient', %args);
	return $self;
}

sub stops
{
	my ($self) = @_;
	return $self->getChildren;
}

return 1;
