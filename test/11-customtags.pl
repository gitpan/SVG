#!/usr/bin/perl -w
use strict;
use SVG qw(star planet moon);

my $svg=new SVG;
print("Failed in custom tags") and exit(0)
	unless eval {
		$svg->star(id=>"Sol")->planet(id=>"Jupiter")->moon(id=>"Ganymede");
	};

print("Failed in invalid tags") and exit(0)
	if eval {
		$svg->asteriod(id=>"Ceres");
	};

exit 1;
