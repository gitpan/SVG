=pod

=head1 NAME

SVG - perl extention for  generating SVG (scalable-vector-graphics)

=cut

=pod

=head1 METHODS

L<attrib> L<animate> L<cdata> L<circle>  L<defs> L<desc>  L<ellipse> L<fe> L<get_path> L<group> L<image> L<line> L<mouseaction>  L<new>  L<path> L<polygon> L<rectangle> L<script> L<style> L<SVG> L<text> L<title>  L<use> L<xmlify> 


=cut

=pod

=head1 SYNOPSIS
  #!/usr/bin/perl -w

  use SVG;
  use strict; 

  #if we are generating a cgi document
  #
  #
  use CGI ':new :header';
  my $p = CGI->new;
  $| = 1;
  print $p->header('image/svg-xml');
  #
  #
  #Now we generate the SVG

  #SVG part of the script
  my $svg= SVG->new(width=>200,height=>200); 
  # use a method to generate a tag tag
  my $y=$svg->group( id     =>  'group_y',
     style  =>  {stroke=>'red', fill=>'green'} );


  $y->circle(cx=>100,cy=>100,
     r=>50,id=>'circle_y',);

  # or use a generic method to generate the tag

  my $z=$svg->tag('g',  id=>'group_z',
     style=>{ stroke=>'rgb(100,200,50)', 
     fill=>'rgb(10,100,150)'} );

  $z->tag('circle',cx=>50, cy=>50,
     r=>100, id=>'circle_z',);
  
  # an anchor with a rectangle within group within group z

  my $k = $z -> anchor(
		     -href   => 'http://test.hackmare.com/',
		     -target => 'new_window_0') -> 
                      rectangle ( x=>20,
                                      y=>50,
                                      width=>20,
                                      height=>30,
                                      rx=>10,
                                      ry=>5,
                                      id=>'rect_z',);
  
  
  
  print $svg->xmlify;

=cut

=pod

=head1 DESCRIPTION

SVG is a 100% perl module which generates a nested data structure which contains the DOM representation of an SVG image. Using SV, You can generate SVG objects, embed other SVG instances within it, access the DOM object, create and access javascript, and generate SMIL animation content. 

=head2 EXPORT

None


=head1 AUTHOR

Ronan Oger, ronan@roasp.com

=head1 SEE ALSO

perl(1)
SVG::Utils
http://roasp.com/

=cut

package SVG;
$VERSION = "0.28";
use strict;
use vars qw( @ISA $AUTOLOAD );
@ISA = qw( SVG::Element );
use SVG::Utils;

=pod

=head2 SVG

=item $svg = SVG->new %properties

Creates a new svg object.

=cut

sub new {
	my $class=shift @_;
	my %attrs=@_;
  my $self;
  if ($attrs{-inline}) {
    $self = $class->SUPER::new('parent',%attrs);
    delete $attrs{-inline};
    $self->svg(%attrs);
  } else {
	  $self = $class->SUPER::new('svg',%attrs);
  }
	$self->{-level}=0;
	$self->{-indent}="\t";
	return($self);
}

=pod

=item $xmlstring = $svg->xmlify %attributes

Returns xml representation of svg document.

B<XML Declaration>

 Name       Default Value
 version         '1.0'
 encoding        'UTF-8'
 standalone      'yes'
 namespace       'svg' 
 -inline         '0'         If '1', then this is an inline document
                             and is intended for use inside an XML document.

 identifier      '-//W3C//DTD SVG 1.0//EN';
 dtd             'http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd'  

=cut

sub xmlify {
	my ($self,%attrs) =shift @_;
  my ($xml,$ns);
  if ($attrs{-inline}) {
#    print "printing parentdecl;";
    ($xml,$ns)=parentdecl(%attrs);
  } else {
#    print "printing dtddecl;";
    ($xml,$ns)=dtddecl(%attrs);
  }
	$xml.=$self->SUPER::xmlify($ns);
  return($xml);
}

package SVG::Element;

use strict;
use vars qw( @ISA $AUTOLOAD );
@ISA = qw( SVG::Utils );
use SVG::Utils;


sub xmlify {
	my ($self,$ns) = shift @_;
	my %attrs;
	foreach my $k (keys(%{$self})) {
		if($k=~/^\-/) { next; }
		if(ref($self->{$k}) eq 'ARRAY') {
			$attrs{$k}=join(', ',@{$self->{$k}});
		} elsif(ref($self->{$k}) eq 'HASH') {
			$attrs{$k}=cssstyle(%{$self->{$k}});
		} elsif(ref($self->{$k}) eq '') {
			$attrs{$k}=$self->{$k};
		}
	}
	my $xml;
	if(defined $self->{-cdata}) {
		$xml=$self->{-indent} x $self->{-level} . xmltagopen($self->{-name},$ns,%attrs);
		$xml.=xmlescp($self->{-cdata});
		$xml.=xmltagclose_ln($self->{-name},$ns);
	} elsif(defined $self->{-childs}) {
		$xml=$self->{-indent} x $self->{-level} . xmltagopen_ln($self->{-name},$ns,%attrs);
		foreach my $k (@{$self->{-childs}}) {
			if(ref($k)=~/^SVG::Element/) {
				$xml.=$k->xmlify;
			}
		}
		$xml.=$self->{-indent} x $self->{-level} . xmltagclose_ln($self->{-name},$ns);
	} else {
		$xml=$self->{-indent} x $self->{-level} . xmltag_ln($self->{-name},$ns,%attrs);
	}
	return($xml);
}

sub addchilds {
	my $self=shift @_;
	push(@{$self->{-childs}},@_);
	return($self);
}

=pod

=item $tag = $svg->tag $name, %properties

Creates element $name with %properties.

B<Example:>

	$tag = $svg->tag('g', transform=>'rotate(-45)');

=cut

sub tag {
	my ($self,$name,%attrs)=@_;
	my $tag=SVG::Element->new($name,%attrs);
	$tag->{-level}=$self->{-level}+1;
	$tag->{-indent}=$self->{-indent};
	$self->addchilds($tag);
	return($tag);
}

=pod

=item $tag = $svg->anchor %properties

create a url anchor tag. requires a child drawn object or group element.	

B<Example:>
	# a complete anchor with a child tag	
	$tag = $svg->anchor(
		-href=>'http://here.com/some/simpler/svg.svg'
	);
	$tag->circle(cx=>10,cy=>10,r=>1);

	# alternate tag definitions
	$tag = $svg->anchor(
		-href   => 'http://somewhere.org/some/other/page.html',
		-target => 'new_window'
	);

	$tag = $svg->anchor(
		-href   => 'http://someotherwhere.net',
		-target => '_top'
	);

=cut

sub anchor {
	my ($self,%attrs)=@_;
	my $an=$self->tag('a',%attrs);
	$an->{'xlink:href'}=$attrs{-href} if(defined $attrs{-href});
	$an->{'target'}=$attrs{-target} if(defined $attrs{-target});
	return($an);
}


sub svg {
	my ($self,%attrs)=@_;
	my $svg=$self->tag('svg',%attrs);
	return($svg);
}



=pod

=item $tag = $svg->circle %properties

draw a circle at cx,xy with radius r 

B<Example:>

	$tag = $svg->circle(	cx=>4
                      		cy=>2
                      		r=>1,);

=cut

sub circle {
	my ($self,%attrs)=@_;
	my $circle=$self->tag('circle',%attrs);
	return($circle);
}

=pod

=item $tag = $svg->ellipse %properties

draw an ellipse at cx,cy with radii rx,ry

B<Example:>

	$tag = $svg->ellipse(cx=>10
                      cy=>10
                      rx=>5
                      ry=>7
                      id=>'ellipse',
                      style=>{'stroke'=>'red',
                              'fill'=>'green'
                              'stroke-width'=>'4'
                              'stroke-opacity'=>'0.5',
                              'fill-opacity'=>'0.2'});

=cut

sub ellipse {
	my ($self,%attrs)=@_;
	my $ellipse=$self->tag('ellipse',%attrs);
	return($ellipse);
}

=pod

=item $tag = $svg->rectangle %properties

draw a rectangle at (x,y) with width 'width' and height 'height' and side radii 'rx' and 'ry'

B<Example:>

	$tag = $svg->rectangle(	x=>10,
                         	y=>20,
                         	width=>4,
                         	height=>5,
                         	rx=>5.2,
                         	ry=>2.4,
                         	id=>'rect_1',);


=cut

sub rectangle {
	my ($self,%attrs)=@_;
	my $rectangle=$self->tag('rect',%attrs);
	return($rectangle);
}

sub rect {
	my ($self,%attrs)=@_;
	my $rectangle=$self->tag('rect',%attrs);
	return($rectangle);
}

=pod

=item  $tag = $svg->image %properties

draw an image at (x,y) with width 'width' and height 'height' linked to image resource '-href'.

B<Example:>

	$tag = $svg->image(	x=>100,
                         	y=>100,
                         	width=>300,
                         	height=>200,
                          '-href'=>"image.png"
                         	id=>'image_1',);

	$tag = $svg->image(	x=>100,
                      y=>100,
                      width=>300,
                      height=>200,
                      '-href'=>"image.svg"
                      id=>'image_1',);


B<Outputs:>

 <image xlink:href="image.png" x="100" y="100" width="300" height="200"/>

=cut

sub image {
	my ($self,%attrs)=@_;
	my $im=$self->tag('image',%attrs);
	$im->{'xlink:href'}=$attrs{-href} if(defined $attrs{-href});
	return($im);
}

=pod

=item $tag = $svg->use %properties

Retrieve the content from an entity within an SVG document and apply it at (x,y) with width 'width' and height 'height' linked to image resource '-href'.

B<Example:>

	$tag = $svg->use(	x=>100,
                    y=>100,
                    width=>300,
                    height=>200,
                    '-href'=>"image.svg#image_1"
                    id=>'image_1',);


B<Outputs:>

   <use xlink:href="image.svg#image_1"  x="100" y="100" width="300" height="200"/>


According to the SVG specification, the 'use' element in SVG can point to a single element within an external SVG file.

SEE ALSO:

L<anchor>.

=cut

sub use {
	my ($self,%attrs)=@_;
	my $u=$self->tag('image',%attrs);
	$u->{'xlink:href'}=$attrs{-href} if(defined $attrs{-href});
	return($u);
}

=pod

=item $tag = $svg->polygon %properties

draw an n-sided polygon with vertices at points defined by string 'x1 y1,x2 y2,x3 y3,...xy yn'. use method get_path to generate the string.

B<Example:>

  # a five-sided polygon

  my $xv = [0,2,4,5,1];

  my $yv = [0,0,2,7,5];

  $points = $a->get_path(x=>$xv,
                          y=>$yv,
                        -type=>'polygon',);

  $c = $a->polygon (%$points,
                    id=>'pgon1',
                    style=>\%polygon_style);

SEE ALSO:

L<polyline>.

L<path>.

L<get_path>.

=cut

sub polygon {
	my ($self,%attrs)=@_;
	my $polygon=$self->tag('polygon',%attrs);
	return($polygon);
}

=pod

=item $tag = $svg->polyline %properties

draw an n-point polyline with points defined by string 'x1 y1,x2 y2,...xn yn'.
use method get_path to generate the vertices from two array references.

B<Example:>

  # a 10-pointsaw-tooth pattern

  my $xv = [0,1,2,3,4,5,6,7,8,9];

  my $yv = [0,1,0,1,0,1,0,1,0,1];

  $points = $a->get_path(x=>$xv,
                          y=>$yv,
                        -type=>'polyline',
                        -closed=>'true'); #specify that the polyline is closed.

  my $tag = $a->polyline (%$points,
                    id=>'pline_1',
                    style=>{'fill-opacity'=>0,
                            'stroke-color'=>'rgb(250,123,23)'}
                    );


SEE ALSO:

L<get_path>.

=cut

sub polyline {
	my ($self,%attrs)=@_;
	my $polyline=$self->tag('polyline',%attrs);
	return($polyline);
}

=pod

=item $tag = $svg->line %properties

draw a straight line between two points (x1,y1),(x2,y2).

B<Example:>

  my $tag = $svg->line( id=>'l1',
                        x1=>0,
                        y1=>0,
                        x2=>10,
                        y2=>10,);

SEE ALSO:

L<polyline>.

=cut


sub line {
	my ($self,%attrs)=@_;
	my $line=$self->tag('line',%attrs);
	return($line);
}

=pod

=item $text = $svg->text %properties

define the container for a text string to be drawn in the image.

B<Example:>

  my $text = $svg->text( id=>'l1',x=>10
                        y=>10,) -> cdata('hello, world');

SEE ALSO:

L<desc>.

L<cdata>.

=cut


sub text {
	my ($self,%attrs)=@_;
	my $text=$self->tag('text',%attrs);
	return($text);
}

=pod

=item $tag = $svg->title %properties

generate the description of the image.

B<Example:>

  my $tag = $svg->title( id=>'root-title')->cdata('hello this is the title');

=cut


sub title {
	my ($self,%attrs)=@_;
	my $title=$self->tag('title',%attrs);
	return($title);
}

=pod

=item $tag = $svg->desc %properties

generate the description of the image.

B<Example:>

  my $tag = $svg->desc( id=>'root-desc')->cdata('hello this is a description');

=cut


sub desc {
	my ($self,%attrs)=@_;
	my $desc=$self->tag('desc',%attrs);
	return($desc);
}


=pod

=item $tag = $svg->script %properties

B<Example:>

  my $tag = $svg->script(type=>"text/ecmascript");

  # populate the script tag with cdata
  # be careful to manage the javascript line ends.
  # qq|text| or qq§text§ where text is the script 
  # works well for this.

  $tag->cdata(qq|function d(){//simple display function
        for(cnt = 0; cnt < d.length; cnt++)
          document.write(d[cnt]);//end for loop
        document.write("<BR>");//write a line break
      }//end function|);

=cut


sub script {
	my ($self,%attrs)=@_;
  my $script=$self->tag('text',%attrs);
	return($script);
}


=pod

=item $tag = $svg->path %properties

B<Example:>

  # a 10-pointsaw-tooth pattern drawn with a path definition

  my $xv = [0,1,2,3,4,5,6,7,8,9];

  my $yv = [0,1,0,1,0,1,0,1,0,1];

  $points = $a->get_path(x=>$xv,
                          y=>$yv,
                        -type=>'path',
                        -closed=>'true'); #specify that the polyline is closed.

  $tag = $svg->path (%$points,
                    id=>'pline_1',
                    style=>{'fill-opacity'=>0,
                            'fill-color'=>'green',
                            'stroke-color'=>'rgb(250,123,23)'}
                    );


SEE ALSO:

L<get_path>.

=cut

sub path {
	my ($self,%attrs)=@_;
	my $path=$self->tag('path',%attrs);
	return($path);
}


=pod

=item $path = $svg->get_path %properties

A method which returns the text string of points correctly formatted to be incorporated into the multi-point SVG drawing object definitions (path, polyline, polygon)

 input:

 output: a hash reference consisting of the following key-value pair:
 points = the appropriate points-definition string
 type = path|polygon|polyline
 -relative = 1 (points define relative position rather than absolute position)
 -closed = 1 (close the curve - path and polygon only)

B<Example:>

 #generate an open path definition for a path.
 my ($points,$p);
 $points = $svg->get_path(x=>\@x,y=>\@y,-relative=>1,type=>'path');
 
 #add the path to the SVG document 
 my $p = $svg->path( %$path,
                  style=>\%style_definition); 

 #generate an closed path definition for a a polyline.
 $points = $svg->get_path( x=>\@x,
                        y=>\@y,
                        -relative=>1,
                        -type=>'polyline',
                        -closed=>1); # generate a closed path definition for a polyline

 # add the polyline to the SVG document
 $p = $svg->polyline (%$points,
                    id=>'pline1',);

=cut

#-----------


sub get_path {
  my ($self,%attrs) = @_;

  my $type = $attrs{-type} || 'path';
  my @x = @{$attrs{x}};
  my @y = @{$attrs{y}};
  my $points;
  # we need a path-like point string returned
  if (lc($type) eq 'path') {
    my $char = 'M';
    $char = ' m ' if (defined $attrs{-relative} && lc($attrs{-relative}));
    while (@x) {
      #scale each value
      my $x = shift @x;
      my $y = shift @y;
      #append the scaled value to the graph
      $points .= "$char $x $y ";
      $char = ' L ';
      $char = ' l ' if (defined $attrs{-relative} && lc($attrs{-relative}));
    }
    $points .=  ' z ' if (defined $attrs{-closed} && lc($attrs{-closed}));
    my %out = (d => $points);
    return \%out;
  } elsif (lc($type) =~ /^poly/){
      while (@x) {
      #scale each value
      my $x = shift @x;
      my $y = shift @y;
      #append the scaled value to the graph
      $points .= "$x,$y ";
    }  
  } 
  my %out = ( points => $points);
  return \%out;
}

sub make_path {
  my ($self,%attrs) = @_;
  return get_path(%attrs);
}

sub set_path {
  my ($self,%attrs) = @_;
  return get_path(%attrs);
}

=pod

=item animate(\%params)

Generate an SMIL animation tag. This is allowed within any of the nonempty tags.
Refer to the W3C for detailed information on the subtleties of the animate SMIL commands.

 inputs: -method = Transform | Motion | Color

=cut

sub animate {
	my ($self,%attrs) = @_;
  my %rtr = %attrs;
 	my $method = $rtr{'-method'}; # Set | Transform | Motion | Color
  
  $method = lc($method);
  
  # we do not want this to pollute the generation of the tag
  delete $rtr{-method};  #bug report from briac.

	my %animation_method = (transform=>'animateTransform',
			 motion=>'animateMotion',
			 color=>'animateColor',
			 set=>'set');
	
	my $name = $animation_method{$method} || 'simple';
	
	#list oflegal entities for each of the 5 methods of animations
	my %legal = (
  'simple'	=>	
     qq§ begin dur  end  min  max  restart  repeatCount 
     repeatDur  fill  attributeType attributeName additive  
     accumulate calcMode  values  keyTimes  keySplines  
     from  to  by §,
  'animateTransform'	=>	
    qq§ begin dur  end  min  max  restart  repeatCount  
    repeatDur  fill  additive  accumulate calcMode  values 
    keyTimes  keySplines  from  to  by calcMode path keyPoints 
    rotate origin type §,
	'animateMotion'		=>	
    qq§ begin dur  end  min  max  restart  repeatCount  
    repeatDur  fill  additive  accumulate calcMode  values  
    to  by keyTimes keySplines  from  path  keyPoints  
    rotate  origin §,
  'animateColor'		=>	
    qq§ begin dur  end  min  max  restart  repeatCount  
    repeatDur  fill  additive  accumulate calcMode  values  
    keyTimes  keySplines  from  to  by §,
  'set'				=>	
    qq§ begin dur  end  min  max  restart  repeatCount  repeatDur  
    fill to §);

	foreach my $k (keys %rtr) {
		if ($legal{$name} !~ /$k/gs) {
			$self->{errors}{"$name.$k"} = 'Illegal animation command';
		}
	}

  my $animate=$self->tag($name,%rtr);

  return($animate);
}


=pod

=item $tag = $svg->group %properties

define a group of objects with common properties. groups can have style, animation, filters, transformations, and mouse actions assigned to them.

B<Example:>

	$tag = $svg->group(
		id        => 'xvs000248',
		style     => {
			'font'      => [ qw( Arial Helvetica sans ) ],
			'font-size' => 10,
			'fill'      => 'red',
		},
		transform => 'rotate(-45)'
	);

=cut

sub group {
	my ($self,%attrs)=@_;
	my $an=$self->tag('g',%attrs);
	return($an);
}

=pod

=item $tag = $svg->defs %properties

define a definition segment. A Defs requires children

B<Example:>

	$tag = $svg->defs(id  =>  'def_con_one',);

=cut

sub defs {
	my ($self,%attrs)=@_;
	my $defs=$self->tag('defs',%attrs);
	return($defs);
}


=pod

=item $svg->style %styledef

Sets/Adds style-definition for the following objects being created.

Style definitions apply to an object and all its children for all properties for which the value of the property is not redefined by the child.

=cut

sub style {
	my ($self,%attrs)=@_;
	$self->{style}=$self->{style} || {};
	foreach my $k (keys %attrs) {
		$self->{style}->{$k}=$attrs{$k};
	}
	return($self);
}

=pod

=item $svg->mouseaction %styledef

Sets/Adds mouse action definitions for tag

=cut

sub mouseaction {
	my ($self,%attrs)=@_;
	$self->{mouseaction}=$self->{mouseaction} || {};
	foreach my $k (keys %attrs) {
		$self->{mouseaction}->{$k}=$attrs{$k};
	}
	return($self);
}

=pod

=item $svg->mouseaction %styledef

Sets/Adds mouse action definitions.

=item $svg->attrib $name, $val

=item $svg->attrib $name, \@val

=item $svg->attrib $name, \%val

Sets attribute to val for a tag.
}

=cut

sub attrib {
	my ($self,$name,$val)=@_;
	$self->{$name}=$val;
	return($self);
}

=pod

=item $svg->cdata $text

Sets cdata to $text.

B<Example:>

	$svg->text(style=>{'font'=>'Arial','font-size'=>20})->cdata('SVG.pm is a perl module on CPAN!');

  my $text = $svg->text(style=>{'font'=>'Arial','font-size'=>20});
  $text->cdata('SVG.pm is a perl module on CPAN!');


B<Result:>

	E<lt>text style="font: Arial; font-size: 20" E<gt>SVG.pm is a perl module on CPAN!E<lt>/text E<gt>

  SEE ALSO:

  L<desc>.

  L<text>.

  L<script>.

=cut

sub cdata {
	my ($self,@txt)=@_;
	$self->{-cdata}=join(' ',@txt);
	return($self);
}


#----------------------

sub AUTOLOAD {
        my($class,$sub)=($AUTOLOAD=~/(.*)::([^:]+)$/);
	my $self=shift @_;
##	print STDERR qq(Undefined call to class='$class' sub='$sub' vars=').join(',',@_).qq('\n);
	if($sub eq 'something') {
	} elsif($sub eq 'DESTROY') {
		$self->release;
	} else {
		$self->{$sub}=$_[0];
	}
	return($self);
}


=pod

=item $tag = $svg->filter %properties

Generate a filter. Filter elements contain L<fe> filter sub-elements

B<Example:>

	$filter = $svg->filter(filterUnits=>"objectBoundingBox",
                      x=>"-10%",
                      y=>"-10%",
                      width=>"150%",
                      height=>"150%",
                      filterUnits=>'objectBoundingBox',);

  $filter->fe();

SEE ALSO:

L<fe>.

=cut


sub filter {
	my ($self,%attrs)=@_;
	my $f=$self->tag('filter',%attrs);
	return($f);
}

=pod

=item $tag = $svg->fe (-type=>'type', %properties)

Generate a filter sub-element Must be a child of a L<filter> element. 

B<Example:>

	$fe = $svg->fe(-type      => 'DiffuseLighting'  #Required. the name of the element with 'fe' ommitted
		              id        => 'filter_1',
		              style     => {'font'      => [ qw( Arial Helvetica sans ) ],
                                'font-size' => 10,
                                'fill'      => 'red',},
              		transform => 'rotate(-45)' );

The following filter elements are currently supported:

feBlend, 
feColorMatrix, 
feComponentTransfer, 
feComposite,
feConvolveMatrix, 
feDiffuseLighting, 
feDisplacementMap, 
feDistantLight, 
feFlood, 
feFuncA, 
feFuncB, 
feFuncG, 
feFuncR, 
feGaussianBlur, 
feImage, 
feMerge, 
feMergeNode, 
feMorphology, 
feOffset, 
fePointLight,
feSpecularLighting, 
feSpotLight, 
feTile, 
feTurbulence, 


SEE ALSO:

L<filter>.

=cut

sub fe {
  my ($self,%attrs) = @_;
  return 0 unless  ($attrs{'-type'});
  my %allowed = (blend => 'feBlend',
              colormatrix => 'feColorMatrix',
              componenttrans => 'feComponentTrans',
              composite => 'feComposite',
              convolvematrix => 'feConvolveMatrix',
              diffuselighting => 'feDiffuseLighting',
              displacementmap => 'feDisplacementMap',
              distantlight => 'feDistantLight',
              flood => 'feFlood',
              funca => 'feFuncA',
              funcb => 'feFuncB',
              funcg => 'feFuncG',
              funcr => 'feFuncR',
              gaussianblur => 'feGaussianBlur',
              image => 'feImage',
              merge => 'feMerge',
              mergenode => 'feMergeNode',
              morphology => 'feMorphology',
              offset => 'feOffset',
              pointlight => 'fePointLight',
              specularlighting => 'feSpecularLighting',
              spotlight => 'feSpotLight',
              tile => 'feTile',
              turbulence => 'feTurbulence',);

  my $key = lc($attrs{'-type'});
  my $fe_name = $allowed{$key} || 'error:illegal_filter_element';
  delete  $attrs{'-type'};
  my $fe = $self->tag($fe_name, %attrs );
}


=pod

=item $tag = $svg->pattern %properties

Define a pattern

B<Example:>

	my $pattern = $svg->pattern( id=>"Argyle_1",
                        width=>"50",
                        height=>"50",
                        patternUnits=>"userSpaceOnUse",
                        patternContentUnits=>"userSpaceOnUse");


=cut

sub pattern {
	my ($self,%attrs)=@_;
	my $pat=$self->tag('pattern',%attrs);
	return $pat;
}


=pod

=item $tag = $svg->set %properties

set a value for an existing element

B<Example:>

	my $set = $svg->set( id=>"Argyle_1",
                        width=>"50",
                        height=>"50",
                        patternUnits=>"userSpaceOnUse",
                        patternContentUnits=>"userSpaceOnUse");


=cut

sub set {
	my ($self,%attrs)=@_;
	my $set=$self->tag('set',%attrs);
	return($set);
}


=pod

=item $tag = $svg->stop %properties

Define a stop

B<Example:>

	my $pattern = $svg->stop( id=>"Argyle_1",
                        width=>"50",
                        height=>"50",
                        patternUnits=>"userSpaceOnUse",
                        patternContentUnits=>"userSpaceOnUse");


=cut

sub stop {
	my ($self,%attrs)=@_;
	my $stop=$self->tag('stop',%attrs);
	return($stop);
}

=pod

=item $tag = $svg->stop %properties

Define a stop

B<Example:>

	my $gradient = $svg->gradient( -type=>'linear',
                        id=>"gradient_1",);


=cut

sub gradient {
	my ($self,%attrs)=@_;
  my $type =  $attrs{-type} || 'linear';
  unless ($type =~ /^(linear|radial)$/) {
    $type = 'linear';
  }  
  delete $attrs{-type};
  my $grad=$self->tag($type.'Gradient',%attrs);
	return($grad);
}

1;



=pod 


h1<The following elements have not yet been implemented as of this release:>

Although these elements do not have an explicit constructor, they can be constructed using the $svg->tag(%attra) generic element.

not-yet implemented elements: 

              altGlyph 
              altGlyphDef 
              altGlyphItem 
              clipPath 
              color-profile 
              cursor 
              definition-src 
              font-face-format 
              font-face-name 
              font-face-src 
              font-face-uri 
              foreignObject 
              glyph 
              glyphRef 
              hkern 
              marker 
              mask 
              metadata 
              missing-glyph 
              mpath 
              pattern 
              radialGradient
              linearGradient
              switch 
              symbol 
              textPath 
              tref 
              tspan 
              view 
              vkern 

=cut