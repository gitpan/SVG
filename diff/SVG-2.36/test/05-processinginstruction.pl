#!/usr/bin/perl -w


#!/usr/bin/perl -w
use strict;
use SVG;

# test: pi

my $svg=new SVG(width=>100,height=>100);
my $xml;

my $pi = $svg->pi("Hello world","I am a PI");
$svg->rect(x=>0,y=>0,width=>10,height=>10,fill=>'red',stroke=>'brick');
$svg->rect(x=>0,y=>0,width=>10,height=>10,fill=>'red',stroke=>'brick');
$svg->rect(x=>0,y=>0,width=>10,height=>10,fill=>'red',stroke=>'brick');
$svg->rect(x=>0,y=>0,width=>10,height=>10,fill=>'red',stroke=>'brick');
$svg->rect(x=>0,y=>0,width=>10,height=>10,fill=>'red',stroke=>'brick');
$svg->rect(x=>0,y=>0,width=>10,height=>10,fill=>'red',stroke=>'brick');
$svg->rect(x=>0,y=>0,width=>10,height=>10,fill=>'red',stroke=>'brick');
$xml = $svg->xmlify();
print("Failed on pi 1: ") and exit(0)
	unless $xml=~/<\?Hello\sworld\?>/gs;
print("Failed on pi 2: ") and exit(0)
	unless $xml=~/<\?I\sam\sa\sPI\?>/gs;


print("Failed on pi 2: add non-PI elements") and exit(0)
	unless $xml=~/rect/gs;

print("Failed on pi 3: fetch PI array") and exit (0)
	unless (scalar @{$svg->pi} ==  2);

$svg->pi("Third PI entry");

$xml = $svg->xmlify();
print("Failed on pi 4: add PI to existing PI array") and exit(0)
	unless $xml=~/<\?Third\sPI\sentry\?>/gs;

print("Failed on pi 3: fetch new PI array") and exit (0)
	unless (scalar @{$svg->pi} ==  3);

exit 1;
