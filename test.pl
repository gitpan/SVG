BEGIN { $| = 1; print "1..3\n"; }

#################################

{
   my $ntest=1;

   sub ok {
       return "ok ".$ntest++."\n";
   }

   sub not_ok {
       return "not ok ".$ntest++."\n";
   }
}

### Tests #######################

END {print "not ok 1\n" unless $loaded;}
use SVG;
$loaded = 1;
print ok;

{
    my $svg=new SVG;
	print $svg?ok:not_ok;
}

{
	my $svg=new SVG;
	my $tag=$svg->circle();
	print $tag?ok:not_ok;
}

#################################

