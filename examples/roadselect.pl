#!/usr/bin/perl -w

BEGIN {
  push @INC , '../';  
  push @INC , '../SVG';
}

use strict;
use SVG;
my $svg  = SVG->new(width=>"100%", height=>"100%", onload=>"init(evt)");
$svg->script()->CDATA(qq§
        var SVGDoc;
        var groups = new Array();
        var last_group;
        
        /*****
        *
        *   init
        *
        *   Find this SVG's document element
        *   Define members of each group by id
        *
        *****/
        function init(e) {
            SVGDoc = e.getTarget().getOwnerDocument();
            append_group(1, 4, 6); // group 0
            append_group(5, 4, 3); // group 1
            append_group(2, 3);    // group 2
            append_group(1, 4, 6);    // group 3
        }
        /*****
        *
        *   append_group
        *
        *   Build an array of elements and append to
        *   group array
        *
        *****/
        function append_group() {
            var roads = new Array();
            for (var i = 0; i < arguments.length; i++) {
                var index = arguments[i];
                var road  = SVGDoc.getElementById("road" + index);
                roads[roads.length] = road;
            }
            groups[groups.length] = roads;
        }
        /*****
        *
        *   set_group_color
        *
        *   Set last group elements to default color
        *   Set all elements in new group to specified color
        *
        *****/
        function set_group_color(group_index, color) {
            if ( last_group != null ) {
                _set_group_color(last_group, "black");
            }
            _set_group_color(group_index, color);
            last_group = group_index;
        }
        
        /*****
        *
        *   _set_group_color
        *
        *   Loop through all elements in group and set
        *   stroke to specified color.
        *   Each element in the group is brought to the
        *   top of the drawing order to clean up
        *   intersections
        *
        *****/
        function _set_group_color(group_index, color) {
            var roads = groups[group_index];
            for (var i = 0; i < roads.length; i++) {
                var road = roads[i];
                
                road.setAttribute("stroke", color);
                road.getParentNode.appendChild(road);
            }
        }
        §);

my $g1 = $svg->group(stroke=>"black", 'stroke-width'=>"4pt", 'stroke-linecap'=>"square");

my $items = int(rand(3))+4;

foreach my $id (0..$items) {
  my @x = (int(rand(20)));
  my @y = (int(rand(20)));
  foreach my $i (0..int(rand(5))) {
    my $xi = int(rand(205));
    my $yi = int(rand(205));
    push @x,$xi;
    push @y,$yi;
  }
  my $path = $svg->get_path(-type=>'polyline',x=>\@x,y=>\@y);
  $g1->polyline(id=>'road'.$id,%$path,'fill-opacity'=>'0');
}
my $ty = 10;
foreach my $i (1..4) {
  my $color = 'rgb('.int(rand(255)).','.int(rand(255)).','.int(rand(255)).')';
  my $g = $svg->group(onmousedown=>"set_group_color($i-1, '$color')");
  $g->circle(cx=>"230", cy=>$ty, r=>"5", fill=>"$color");
  $g->text( x=>"240", y=>$ty+4 )->cdata("Group $i");
  $ty += 15;
}



print "Content-Type: image/svg+xml\n\n";

print $svg->xmlify;

__END__


-------------
<?xml version="1.0"?>
<svg width="100%" height="100%" onload="init(evt)">
    <g onmousedown="set_group_color(0, 'blue')">
        <circle cx="130" cy="10" r="5" fill="blue"/>
        <text x="140" y="14">Group 1</text>
    </g>
    <g onmousedown="set_group_color(1, 'green')">
        <circle cx="130" cy="25" r="5" fill="green"/>
        <text x="140" y="29">Group 2</text>
    </g>
    <g onmousedown="set_group_color(2, 'red')">
        <circle cx="130" cy="40" r="5" fill="red"/>
        <text x="140" y="44">Group 3</text>
    </g>
</svg>


-------------
