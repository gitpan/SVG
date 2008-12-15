use Test::More tests=>3;
use strict;
use SVG;

# test: style

my $svg  = new SVG;
ok(my $out1 = $svg->text()->cdata_noxmlesc(SVG::xmlescp("><!&")),"toxic characters to xmlescp");
ok(my $out2 = $svg->text()->cdata("><!&"),"toxic characters to cdata");

$svg->xmlify();
ok($out1->xmlify() eq $out2->xmlify(),"xmlesc helper");
