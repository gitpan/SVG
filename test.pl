#!/usr/bin/perl -w

use strict;
use vars qw($loaded);

# pass on the @INC passed to us to the individual tests
$ENV{PERL5LIB}=join ':',@INC;

#-------------------------------------------------------------------------------

$| = 1;

#-------------------------------------------------------------------------------

{
    my $ntest=1;
    sub ok      { return "ok ".$ntest++."\n"; }
    sub not_ok  { return "not ok ".$ntest++."\n"; }
    sub skipped { return "skipped ".$ntest++."\n"; }
}

#-------------------------------------------------------------------------------

my @tests=<test/*.pl>;

print "1..",scalar(@tests),"\n";

foreach my $test (@tests) {
  my $result=system("perl","-w",$test) >> 8;
  print $result?($result==2?skipped:ok):" ".not_ok;
}

