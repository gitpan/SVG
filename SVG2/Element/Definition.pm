package SVG2::Element::Definition;

use base "XML2::Element";

use strict;
use warnings;

sub new
{
    my ($proto, $def, %args) = @_;
    my $self = $proto->SUPER::new($def, %args);
	$self->document->addDefinition($self);
	return $self;
}

return 1;
