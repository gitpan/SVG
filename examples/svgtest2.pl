#!/usr/bin/perl

use strict;
use CGI;

use SVG;

#---------Create the CGI object which is required to handle the header
my $p = CGI->new();

$| = 1;


#---------print the header just before outputting to screen




#---------

#---------Create the svg object

my $height = $p->param('h') || 400;
my $width = $p->param('w') || 800;

my $svg= SVG->new(width=>$width,height=>$height); 

my %line_style = ('stroke-miterlimit'=>(4*rand()),
          'stroke-linejoin'=>'miter',
          'stroke-linecap'=>'round',
          'stroke-width'=>(0.1+5*rand()),
          'stroke-opacity'=>(0.5+0.5*rand()),
          'stroke'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'fill-opacity'=>(0.5+0.5*rand()),
          'fill'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'opacity'=>(0.5+0.5*rand()) );
          
my %circle_style = ('stroke-miterlimit'=>(4*rand()),
          'stroke-linejoin'=>'miter',
          'stroke-linecap'=>'round',
          'stroke-width'=>(0.1+0.5*rand()),
          'stroke-opacity'=>(0.5+0.5*rand()),
          'stroke'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'fill-opacity'=>(0.5+0.5*rand()),
          'fill'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'opacity'=>(0.5+0.5*rand()) );

my %polyline_style = ('stroke-miterlimit'=>(4*rand()),
          'stroke-linejoin'=>'miter',
          'stroke-linecap'=>'round',
          'stroke-width'=>(0.1+0.5*rand()),
          'stroke-opacity'=>(0.5+0.5*rand()),
          'stroke'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'fill-opacity'=>(0.5+0.5*rand()),
          'fill'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'opacity'=>(0.5+0.5*rand()) );

my %rectangle_style = ('stroke-miterlimit'=>(4*rand()),
          'stroke-linejoin'=>'miter',
          'stroke-linecap'=>'round',
          'stroke-width'=>(0.1+0.5*rand()),
          'stroke-opacity'=>(0.5+0.5*rand()),
          'stroke'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'fill-opacity'=>(0.5+0.5*rand()),
          'fill'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'opacity'=>(0.5+0.5*rand()) );


my %polygon_style = ('stroke-miterlimit'=>(4*rand()),
          'stroke-linejoin'=>'miter',
          'stroke-linecap'=>'round',
          'stroke-width'=>(0.1+0.5*rand()),
          'stroke-opacity'=>(0.5+0.5*rand()),
          'stroke'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'fill-opacity'=>(0.5+0.5*rand()),
          'fill'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'opacity'=>(0.5+0.5*rand()) );


my %text_style = ('font-family'=>'Arial',
          'font-size'=>8+5*rand(),
          'stroke-width'=>1+2*rand(),
          'stroke-opacity'=>(0.5+0.5*rand()),
          'stroke'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'fill-opacity'=>1,
          'fill'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'opacity'=>(0.5+0.5*rand()) );

my %text_style_1 = ('font-family'=>'Arial',
          'font-size'=>8+5*rand(),
          'stroke-width'=>1+2*rand(),
          'stroke-opacity'=>(0.5+0.5*rand()),
          'stroke'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'fill-opacity'=>1,
          'fill'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'opacity'=>(0.5+0.5*rand()) );

my %text_style_2 = ('font-family'=>'Arial',
          'font-size'=>8+5*rand(),
          'stroke-width'=>1+2*rand(),
          'stroke-opacity'=>(0.2+0.5*rand()),
          'stroke'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'fill-opacity'=>1,
          'fill'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'opacity'=>(0.5+0.5*rand()) );

my %text_style_3 = ('font-family'=>'Arial',
          'font-size'=>8+5*rand(),
          'stroke-width'=>1+2*rand(),
          'stroke-opacity'=>(0.5+0.2*rand()),
          'stroke'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'fill-opacity'=>1,
          'fill'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'opacity'=>(0.5+0.5*rand()) );

my %text_style_4 = ('font-family'=>'Arial',
          'font-size'=>8+5*rand(),
          'stroke-width'=>1+2*rand(),
          'stroke-opacity'=>(0.5+0.3*rand()),
          'stroke'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'fill-opacity'=>1,
          'fill'=>'rgb('.255*rand().','.255*rand().','.255*rand().')',
          'opacity'=>(0.5+0.5*rand()) );

my $y=$svg->group( id=>'group_generated_group',style=>{ stroke=>'red', fill=>'green' });

my $z=$svg->tag('g',  id=>'tag_generated_group',style=>{ stroke=>'red', fill=>'black' });


my $ya = $y -> anchor(
		-href   => 'http://somewhere.org/some/line.html',
		-target => 'new_window_0');


my $line_transform = 'matrix(0.774447 0.760459 0 0.924674 357.792 -428.792)';

my $line = $svg->line(id=>'l1',x1=>(rand()*$width+5),
          y1=>(rand()*$height+5),
          x2=>(rand()*$width-5),
          y2=>(rand()*$height-5),
          style=>\%line_style,);

#---------
my $myX = -$width*rand();
my $myY = -$height*rand();


$y->rectangle (x=>$width/2,
               y=>$height/2,
               width=>(50+50*rand()),
               height=>(50+50*rand()),
               rx=>20*rand(),
               ry=>20*rand(),
               id=>'rect_1',
               style=>\%rectangle_style);

$y->animate(attributeName=>'transform', 
            attributeType=>'XML',
            from=>'0 0',
            to=>$myX.' '.$myY,
            dur=>20*rand().'s',
            repeatCount=>'20',
            restart=>'always',
            -method=>'Transform',);

my $a = $z -> anchor(
		-href   => 'http://somewhere.org/some/other/page.html',
		-target => 'new_window_0');

my $a1 = $z -> anchor(
		-href   => '/index.html',
		-target => 'new_window_1');

my $a2 = $z -> anchor(
		-href   => '/svg/index.html',
		-target => 'new_window_2');


my $c = $a->circle(cx=>($width-20)*rand(),
                    cy=>($height-20)*rand(),
                    r=>100*rand(), 
                    id=>'c1',
                    style=>\%circle_style);

$c = $a1->circle(cx=>($width-20)*rand(),
                    cy=>($height-20)*rand(),
                    r=>100*rand(), 
                    id=>'c2',
                    style=>\%circle_style);

my $xv = [$width*rand(), $width*rand(), $width*rand(), $width*rand()];

my $yv = [$height*rand(), $height*rand(), $height*rand() ,$height*rand()];

my $points = $a->get_path(x=>$xv,
                          y=>$yv,
                        -type=>'polyline',
                        -closed=>'true',);
                     

$c = $a1->polyline (%$points,
                    id=>'pline1',
                    style=>\%polyline_style);


$xv = [$width*rand(), $width*rand(), $width*rand(), $width*rand()];

$yv = [$height*rand(), $height*rand(), $height*rand() ,$height*rand()];

$points = $a->get_path(x=>$xv,
                          y=>$yv,
                        -type=>'polygon',);


$c = $a->polygon (%$points,
                    id=>'pgon1',
                    style=>\%polygon_style);

my $t=$a2->text(id=>'t1',
                transform=>'rotate(-45)',
                style=>\%text_style);

my $t=$a2->text(id=>'t3',
              x=>$width/2*rand(),
              y=>($height-80)*rand(),
              transform=>'rotate('.(-2.5*5*rand()).')',
              style=>\%text_style_1);

my $v=$a2->tag('text',
              id=>'t5',
              x=>$width/2*rand(),
              y=>$height-40+5*rand(),
              transform=>'rotate('.(-2.5*5*rand()).')',
              style=>\%text_style_3);

my $w=$a2->text(id=>'t5',
              x=>$width/2*rand(),
              y=>$height-20+5*rand(),
              transform=>'rotate('.(-2.5*5*rand()).')',
              style=>\%text_style_4);


$t->cdata('Text generated using the high-level "text" tag');
$v->cdata('Text generated using the low-level "tag" tag');
$w->cdata('Hackmarish perl!');
$w->cdata('and more perl Hackmarish perl!');

print $p->header('image/svg-xml');
print $svg->xmlify;

exit;

__END__

#---------
