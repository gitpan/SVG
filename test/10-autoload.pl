#!/usr/bin/perl -w
use strict;
use SVG (-auto => 1);

my $svg=new SVG(-foo => "bar");
print("Failed in autoload") and exit(0)
    unless eval {
        $svg->make->it->up->as->we->go->along;
    };

#--> currently this is allowed, in fact. It just has no effect.
#print("Failed in rejecting -auto argument") and exit(0)
#    if eval {
#        my $svg=new SVG(-auto => 1);
#	1;
#    };

exit 1;
