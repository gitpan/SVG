package SVGStrict::Element::Definition::radialGradient;

use base "SVGStrict::Element::Definition";

use strict;
use warnings;

sub new
{
    my ($proto, %args) = @_;
    my $self = $proto->SUPER::new('radialGradient', %args);
	return $self;
}

return 1;
