#!/usr/bin/perl -w
use strict;
use SVG;

# test: fe

my $svg=new SVG;
my $parent=$svg->group();
my $child1=$parent->text->cdata("I am the first child");
my $child2=$parent->text->cdata("I am the second child");
my $fe = $svg->fe(
        -type   => 'diffuselighting', # required - element name omiting 'fe'
        id   => 'filter_1',
        style     => {
            'font'      => [ qw(Arial Helvetica sans) ],
            'font-size' => 10,
            'fill'      => 'red',
        },
        transform => 'rotate(-45)'
    );

print ("Failed on fe 1: generation ") and exit(0) unless $fe;
my $out = $svg->xmlify;
print ("Failed on fe 2: result ") and exit(0) unless $out =~ /feDiffuseLighting/;

exit 1;
