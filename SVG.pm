=title SVG.pm - perl-module to generate scalable-vector-graphics

=cut

package SVG;

use strict;
use vars qw( @ISA $AUTOLOAD );
@ISA = qw( SVG::Element );
use SVG::Utils;

=head2 SVG

=item $svg = SVG->new %properties

Creates a new svg object.

=cut

sub new {
	my $class=shift @_;
	my %attrs=@_;
	my $self = $class->SUPER::new('svg',%attrs);
	$self->{-level}=0;
	$self->{-indent}="\t";
	return($self);
}

=item $xmlstring = $svg->xmlify

Returns xml representation of svg document.

=cut

sub xmlify {
	my $self=shift @_;
	my %attrs;
	my $xml=svgdecl();
	$xml.=$self->SUPER::xmlify;
	return($xml);
}

package SVG::Element;

use strict;
use vars qw( @ISA $AUTOLOAD );
@ISA = qw( SVG::Utils );
use SVG::Utils;

=head2 SVG::Element

=item $xmlstring = $svg->xmlify

Returns xml representation of tag and childs.

=cut

sub xmlify {
	my $self=shift @_;
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
		$xml=$self->{-indent} x $self->{-level} . xmltagopen($self->{-name},%attrs);
		$xml.=xmlescp($self->{-cdata});
		$xml.=xmltagclose_ln($self->{-name});
	} elsif(defined $self->{-childs}) {
		$xml=$self->{-indent} x $self->{-level} . xmltagopen_ln($self->{-name},%attrs);
		foreach my $k (@{$self->{-childs}}) {
			if(ref($k)=~/^SVG::Element/) {
				$xml.=$k->xmlify;
			}
		}
		$xml.=$self->{-indent} x $self->{-level} . xmltagclose_ln($self->{-name});
	} else {
		$xml=$self->{-indent} x $self->{-level} . xmltag_ln($self->{-name},%attrs);
	}
	return($xml);
}

sub addchilds {
	my $self=shift @_;
	push(@{$self->{-childs}},@_);
	return($self);
}

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

=item $tag = $svg->anchor %properties

B<Example:>

	$tag = $svg->anchor(
		-href=>'http://here.com/some/simpler/svg.svg'
	);
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


=item $tag = $svg->circle %properties

B<Example:>

	$tag = $svg->circle(cx=>4
                      cy=>2
                      r=>1,);
	);

=cut

sub circle {
	my ($self,%attrs)=@_;
	my $circle=$self->tag('circle',%attrs);
	return($circle);
}

=pod

=item $tag = $svg->ellipse %properties

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

B<Example:>

	$tag = $svg->rectangle(x=>1,
                         y=>2,
                         width=>4,
                         height=>5,
                         rx=>.2,
                         ry=>.4,
                         id=>'rect_1',);


=cut

sub rectangle {
	my ($self,%attrs)=@_;
	my $rectangle=$self->tag('rect',%attrs);
	return($rectangle);
}

=pod

=item $tag = $svg->polygon %properties

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
=cut

sub polygon {
	my ($self,%attrs)=@_;
	my $polygon=$self->tag('polygon',%attrs);
	return($polygon);
}

=pod

=item $tag = $svg->polyline %properties

B<Example:>

  # a 10-pointsaw-tooth pattern

  my $xv = [0,1,2,3,4,5,6,7,8,9];

  my $yv = [0,1,0,1,0,1,0,1,0,1];

  $points = $a->get_path(x=>$xv,
                          y=>$yv,
                        -type=>'polyline',
                        -closed=>'true'); #specify that the polyline is closed.

  $c = $a->polyline (%$points,
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

B<Example:>

  my $tag = $svg->line( id=>'l1',x1=>0
                        y1=>0,
                        x2=>10,
                        y2=>10,);

=cut


sub line {
	my ($self,%attrs)=@_;
	my $line=$self->tag('line',%attrs);
	return($line);
}

sub text {
	my ($self,%attrs)=@_;
	my $text=$self->tag('text',%attrs);
	return($text);
}

=pod

=item $tag = $svg->path %properties

B<Example:>

  # a 10-pointsaw-tooth pattern

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

output: a hash reference consisting of:
points = the appropriate points-definition string



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
  } elsif (lc($type) =~ /poly/){
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

=pod

=item animate(\%params)

Generate an SMIL animation tag. This is allowed within any of the nonempty tags.
Refer to the W3C for detailed information on the subtleties of the animate SMIL commands.

=cut

#XXXXX
sub animate_not_me {
	my ($self,%attrs)=@_;
	$self->{animate}=$self->{animate} || {};
	foreach my $k (keys %attrs) {
		$self->{animate}->{$k}=$attrs{$k};
	}
	return($self);
}

sub animate {
	my ($self,%attrs) = @_;
  my %rtr = %attrs;
 	my $method = $rtr{'-method'}; # Set | Transform | Motion | Color
  
  $method = lc($method);
  
  # we do not want this to pollute the generation of the tag
  delete $rtr{method}; 

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



=item $tag = $svg->group %properties

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

=item $svg->style %styledef

Sets/Adds style-definition.

=cut

sub style {
	my ($self,%attrs)=@_;
	$self->{style}=$self->{style} || {};
	foreach my $k (keys %attrs) {
		$self->{style}->{$k}=$attrs{$k};
	}
	return($self);
}

=item $svg->mouseaction %styledef

Sets/Adds mouse action definitions.

=cut

sub mouseaction {
	my ($self,%attrs)=@_;
	$self->{mouseaction}=$self->{mouseaction} || {};
	foreach my $k (keys %attrs) {
		$self->{mouseaction}->{$k}=$attrs{$k};
	}
	return($self);
}

=item $svg->attrib $name, $val

=item $svg->attrib $name, \@val

=item $svg->attrib $name, \%val

Sets attribute to val.

=cut

sub attrib {
	my ($self,$name,$val)=@_;
	$self->{$name}=$val;
	return($self);
}

=item $svg->cdata $text

Sets cdata to $text.

B<Example:>

	$svg->text(style=>{'font'=>'Arial','font-size'=>20})->cdata('This is a hello to svg !');

B<Result:>

	E<lt>text style="font: Arial; font-size: 20" E<gt> This is a hello to svg ! E<lt>/text E<gt>

=cut

sub cdata {
	my ($self,@txt)=@_;
	$self->{-cdata}=join(' ',@txt);
	return($self);
}


#----------------------


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





=item $tag = $svg->fe %properties

B<Example:>

	$tag = $svg->fe(
    -TYPE => 
		id        => 'xvs000248',
		style     => {
			'font'      => [ qw( Arial Helvetica sans ) ],
			'font-size' => 10,
			'fill'      => 'red',
		},
		transform => 'rotate(-45)'
	);

=cut

sub fe {
  my ($self,%attrs) = @_;
  return 0 unless  ($attrs{-TYPE});
#  next if ($attrs{-TYPE} eq 'feDiffuseLighting');
  my $tag_name = $attrs{-TYPE};
  delete  $attrs{-TYPE};
  my $fe = $self->tag($tag_name, %attrs);
}



1;

__END__

not-yet implemented elements: 
              altGlyph 
              altGlyphDef 
              altGlyphItem 
              clipPath 
              color-profile 
              cursor 
              definition-src 
              defs 
              desc 
              feBlend 
              feColorMatrix 
              feComponentTransfer 
              feComposite 
              feConvolveMatrix 
              feDiffuseLighting 
              feDisplacementMap 
              feDistantLight 
              feFlood 
              feFuncA 
              feFuncB 
              feFuncG 
              feFuncR 
              feGaussianBlur 
              feImage 
              feMerge 
              feMergeNode 
              feMorphology 
              feOffset 
              fePointLight 
              feSpecularLighting 
              feSpotLight 
              feTile 
              feTurbulence 
              filter 
              font 
              font-face 
              font-face-format 
              font-face-name 
              font-face-src 
              font-face-uri 
              foreignObject 
              g 
              glyph 
              glyphRef 
              hkern 
              image 
              line 
              linearGradient 
              marker 
              mask 
              metadata 
              missing-glyph 
              mpath 
              pattern 
              radialGradient 
              rect 
              script 
              set 
              stop 
              style 
              svg 
              switch 
              symbol 
              text 
              textPath 
              title 
              tref 
              tspan 
              use 
              view 
              vkern 
