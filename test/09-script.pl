#!/usr/bin/perl -w
use strict;
use SVG;

my $svg = new SVG;

my $tag = $svg->script( type => "text/ecmascript" );

# populate the script tag with cdata
# be careful to manage the javascript line ends.
# qq│text│ or qq§text§ where text is the script
# works well for this.

my $out;

$tag->CDATA(
    qq|
function d(){
//simple display function
for(cnt = 0; cnt < d.length; cnt++)
document.write(d[cnt]);//end for loop
document.write("<hr>");//write a line break
document.write('<br>');//write a horizontal rule
}|
);

print("Failed on script 1: create script element") and exit(0)
  unless $tag;
$out = $svg->xmlify;

print("Failed on script 2: specify script type") and exit(0)
  unless $out =~ /\"text\/ecmascript\"/;
print("Failed on script 3: generate script content") and exit(0)
  unless $out =~ /function/;
print("Failed on script 4: handle single quotes") and exit(0)
  unless $out =~ /'<br>'/;
print("Failed on script 5: handle double quotes") and exit(0)
  unless $out =~ /"<hr>"/;

#test for adding scripting commands in an element

$out = $svg->xmlify;

my $rect = $svg->rect(
    x       => 10,
    y       => 10,
    fill    => 'red',
    stroke  => 'black',
    width   => '10',
    height  => '10',
    onclick => "alert('hello'+' '+'world')"
);

$out = $rect->xmlify;

print("Failed on script 6: mouse event script call") and exit(0)
  unless ( $out =~ /'hello'/gs && $out =~ /'world'/gs );


$svg = new SVG;
$svg->script()->CDATA("TESTTESTTEST");
$out = $svg->xmlify;
chomp $out;
print("Failed on script 7: script without type") and exit(0)
  unless ( $out =~ /<script\s*><!\[CDATA\[TESTTESTTEST\]\]>\s*<\/script>/);

exit 1;
