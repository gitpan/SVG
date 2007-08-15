#!/usr/bin/perl -w
use strict;
use SVG;

# test: style

my $svg=new SVG;
my $defs = $svg->defs();
my $out;
    # generate an anchor
    my $tag0 = $svg->anchor(
        -href=>'http://here.com/some/simpler/SVG.svg'
    );
    # add a circle to the anchor. The circle can be clicked on.
    $tag0->circle(cx=>10,cy=>10,r=>1);

    # more complex anchor with both URL and target
    $svg->comment("anchor with: -href, target");
    my $tag1 = $svg->anchor(
          -href   => 'http://example.com/some/page.html',
          target => 'new_window_1',
    );
    $tag1->circle(cx=>10,cy=>10,r=>1);

    $svg->comment("anchor with: -href, -title, -actuate, -show");
    my $tag2 = $svg->anchor(
        -href => 'http://example.com/some/other/page.html',
	-actuate => 'onLoad',
        -title => 'demotitle',
	-show=> 'embed',
    );
    $tag2->circle(cx=>10,cy=>10,r=>1);

$out = $tag0->xmlify;
print ("Failed on anchor 3: xlink href") and exit(0) unless
	$out =~ /http\:\/\/here\.com\/some\/simpler\/SVG\.svg/gs;

$out = $tag1->xmlify;
print ("Failed on anchor 4: target") and exit(0) unless
	$out =~ /target\=\"new_window_1\"/gs;

$out = $tag2->xmlify;
print ("Failed on anchor 6: title") and exit(0) unless
	$out =~ /xlink\:title\=\"demotitle\"/gs;
$out = $tag2->xmlify;
print ("Failed on anchor 7: actuate") and exit(0) unless
	$out =~ /actuate/gs;

$out = $tag2->xmlify;
print ("Failed on anchor 8: show") and exit(0) unless
	$out =~ /xlink\:show\=\"embed\"/gs;

    my $tag3 = $svg->a(
        -href   => 'http://example.com/some/page.html',
        -title => 'direct_a_tag',
        target => 'new_window_1',);

$out = $tag3->xmlify;
print ("Failed on anchor 8: direct a method") and exit(0) unless
	$out =~ /direct_a_tag/gs;

exit 1;
