package SVG;
use strict;

use vars qw($VERSION @ISA $AUTOLOAD);
use SVG::Utils;
@ISA = qw(SVG::Element);

$VERSION = "0.50";

#-------------------------------------------------------------------------------

=pod

=head1 NAME

SVG - Perl extension for generating Scalable Vector Graphics (SVG) documents

=head2 VERSION

Version 0.50, 12 October 2001

=head1 METHODS

    C<attrib>, C<animate>, C<cdata>, C<circle>, C<defs>, C<desc>,
    C<ellipse>, C<fe>, C<get_path>, C<group>, C<image>, C<line>,
    C<mouseaction>, C<new>, C<path>, C<polygon>, C<rectangle>, C<script>,
    C<style>, C<SVG>, C<text>, C<title>, C<use>, C<xmlify>

=head1 SYNOPSIS

    #!/usr/bin/perl -w
    use strict;
    use SVG;

    # create an SVG object
    my $svg= SVG->new(width=>200,height=>200);

    # use explicit element constructor to generate a group element
    my $y=$svg->group(
        id    => 'group_y',
        style => { stroke=>'red', fill=>'green' }
    );

    # add a circle to the group
    $y->circle(cx=>100, cy=>100, r=>50, id=>'circle_in_group_y');

    # or, use the generic 'tag' method to generate a group element by name
    my $z=$svg->tag('g',
                    id    => 'group_z',
                    style => {
                        stroke => 'rgb(100,200,50)',
                        fill   => 'rgb(10,100,150)'
                    }
                );

    # create and add a circle using the generic 'tag' method
    $z->tag('circle', cx=>50, cy=>50, r=>100, id=>'circle_in_group_z');
  
    # create an anchor on a rectangle within a group within the group z
    my $k = $z->anchor(
        id      => 'anchor_k',
        -href   => 'http://test.hackmare.com/',
        -target => 'new_window_0'
    )->rectangle(
        x     => 20, y      => 50,
        width => 20, height => 30,
        rx    => 10, ry     => 5,
        id    => 'rect_k_in_anchor_k_in_group_z'
    );

    # now render the SVG object, implicitly use svg namespace
    print $svg->xmlify;

    # or, explicitly use svg namespace and generate a document with its own DTD
    print $svg->xmlify(-namespace=>'svg');

    # or, explicitly use svg namespace and generate an in-line docunent
    print $svg->xmlify(
        namespace => "svg",
        ns_url    => "http://www.w3.org/2000/svg", # SVG namespace
        xmlns     => "http://roasp.com/",          # Document namespace
        -inline   => 1
    );

=head1 DESCRIPTION

SVG is a 100% Perl module which generates a nested data structure containing the
DOM representation of an SVG (Scalable Vector Graphics) image. Using SVG, you
can generate SVG objects, embed other SVG instances into it, access the DOM
object, create and access javascript, and generate SMIL animation content.

=head2 General Steps to generating an SVG document

Generating SVG is a simple three step process:

=over 4

=item 1 The first step is to construct a new SVG object with C<new>.

=item 2 The second step is to call element constructors to create SVG elements.
Examples of element constructors are C<circle> and C<path>.

=item 3 The third and last step is to render the SVG object into XML using the
C<xmlify> method.

=back

The C<xmlify> method takes a number of optional arguments that control how SVG
renders the object into XML, and in particular determine whether a stand-alone
SVG document or an inline SVG document fragment is generated:

=over 4

=item -stand-alone

A complete SVG document with its own associated DTD. A namespace for the SVG
elements may be optionally specified.

=item -in-line

An in-line SVG document fragment with no DTD that be embedded within other XML
content. As with stand-alone documents, an alternate namespace may be specified.

=back

No XML content is generated until the third step is reached. Up until this
point, all constructed element definitions reside in a DOM-like data structure
from which they can be accessed and modified.

=head2 EXPORTS

None

=head1 AUTHOR

Ronan Oger, ronan@roasp.com

=head1 SEE ALSO

    perl(1), L<SVG::Utils>,
    http://roasp.com/
    http://www.w3c.org/Graphics/SVG/

=head1 Methods

SVG provides both explicit and generic element constructor methods. Explicit
generators are generally (with a few exceptions) named for the element they
generate.

All element constructors take a hash of element attributes and instructions;
element attributes such as 'id' are passed by name, while instructions for the
method (such as the type of an element that supports multiple alternate forms)
are passed preceded by a hyphen, e.g '-type'. Both types may be freely
intermixed; see the C<fe> method and code examples througout the documentation
for more examples.

=head2 new (constructor)

=item $svg = SVG->new(%attributes)

Creates a new SVG object.

=cut

sub new ($;@) {
    my ($proto,%attrs)=@_;
    my $class=ref $proto || $proto;

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

    return $self;
}

=pod

=over 4

=head2 xmlify

=item $xmlstring = $svg->xmlify(%attributes)

Returns xml representation of svg document.

B<XML Declaration>

    B<Name>           B<Default Value>
    version           '1.0'
    encoding          'UTF-8'
    standalone        'yes'
    namespace         'svg'                - namespace for elements
    xmlns (inline)    'http://example.org' - see <parent> tag below
    ns_url (inline)   'the url of the xml' - see <parent> tag below
    -inline           '0' - If '1', then this is an inline document.
    identifier        '-//W3C//DTD SVG 1.0//EN';
    dtd (standalone)  'http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd'

B<Parent tag>:

    <parent xmlns="[xmlns]" xmlns:[namespace]="[ns_url]">

For example:

    print $svg->xmlify(
        namespace => "mysvg",
        ns_url    => "http://www.w3.org/2000/svg", # SVG namespace
        xmlns     => "http://roasp.com/",          # Document namespace
        -inline   => 1
    );

B<Output>:

    <parent xmlns="http://roasp.com" xmlns:mysvg="http://www.w3.org/2000/svg">
    <mysvg:svg>
       ...
    </mysvg:svg>

=cut

sub xmlify ($;@) {
    my ($self,%attrs) = @_;

    my ($decl,$ns);
    if ($attrs{'-inline'}) {
        ($decl,$ns)=parentdecl(%attrs);
    } else {
        ($decl,$ns)=dtddecl(%attrs);
    }
    #<<< what about $xml?

    return $decl.$self->SUPER::xmlify($ns);
}

#-------------------------------------------------------------------------------

package SVG::Element;

use strict;
use vars qw( @ISA $AUTOLOAD );
@ISA = qw( SVG::Utils );
use SVG::Utils;

sub xmlify ($$) {
    my ($self,$ns) = @_;

    #prep the attributes
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

    #prep the tag
    my $xml=$self->{-indent} x $self->{-level};
    if(defined $self->{-cdata}) {
        $xml.=xmltagopen($self->{-name},$ns,%attrs);
        $xml.=xmlescp($self->{-cdata});
        $xml.=xmltagclose_ln($self->{-name},$ns);
    } elsif(defined $self->{-childs}) {
        $xml.=xmltagopen_ln($self->{-name},$ns,%attrs);
        foreach my $k (@{$self->{-childs}}) {
            if(ref($k)=~/^SVG::Element/) {
                $xml.=$k->xmlify($ns);
            }
        }
        $xml.=$self->{-indent} x $self->{-level};
        $xml.=xmltagclose_ln($self->{-name},$ns);
    } else {
        $xml.=xmltag_ln($self->{-name},$ns,%attrs);
    }

    #return the finished tag
    return $xml;
}

sub addchilds ($@) {
    my $self=shift;
    push @{$self->{-childs}},@_;
    return $self;
}

=pod

=head2 tag (alias: element)

=item $tag = $svg->tag($name, %attributes)

Generic element generator. Creates the element named $name with the attributes
specified in %attributes. This method is the basis of most of the explicit
element generators.

B<Example:>

    my $tag = $svg->tag('g', transform=>'rotate(-45)');

=cut

sub tag ($$;@) {
    my ($self,$name,%attrs)=@_;
    my $tag=SVG::Element->new($name,%attrs);
    $tag->{-level}=$self->{-level}+1;
    $tag->{-indent}=$self->{-indent};
    $self->addchilds($tag);
    return($tag);
}

*element=\&tag;

=pod

=head2 anchor

=item $tag = $svg->anchor(%attributes)

Generate an anchor element. Anchors are put around objects to make them
'live' (i.e. clickable). It therefore requires a drawn object or group element
as a child.

B<Example:>

    # generate an anchor	
    $tag = $svg->anchor(
        -href=>'http://here.com/some/simpler/svg.svg'
    );
    # add a circle to the anchor. The circle can be clicked on.
    $tag->circle(cx=>10,cy=>10,r=>1);

    # more complex anchor with both URL and target
    $tag = $svg->anchor(
	-href   => 'http://somewhere.org/some/other/page.html',
	-target => 'new_window'
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

=head2 circle

=item $tag = $svg->circle(%attributes)

Draw a circle at (cx,cy) with radius r.

B<Example:>

    my $tag = $svg->circlecx=>4, cy=>2, r=>1);

=cut

sub circle ($;@) {
    my ($self,%attrs)=@_;
    return $self->tag('circle',%attrs);
}

=pod

=head2 ellipse

=item $tag = $svg->ellipse(%attributes)

Draw an ellipse at (cx,cy) with radii rx,ry.

B<Example:>

    my $tag = $svg->ellipse(
        cx=>10, cy=>10,
        rx=>5, ry=>7,
        id=>'ellipse',
        style=>{
            'stroke'=>'red',
            'fill'=>'green',
            'stroke-width'=>'4',
            'stroke-opacity'=>'0.5',
            'fill-opacity'=>'0.2'
        }
    );

=cut

sub ellipse ($;@) {
    my ($self,%attrs)=@_;
    return $self->tag('ellipse',%attrs);
}

=pod

=head2 rectangle (alias: rect)

=item $tag = $svg->rectangle(%attributes)

Draw a rectangle at (x,y) with width 'width' and height 'height' and side radii
'rx' and 'ry'.

B<Example:>

    $tag = $svg->rectangle(
        x=>10, y=>20,
        width=>4, height=>5,
        rx=>5.2, ry=>2.4,
        id=>'rect_1'
    );

=cut

sub rectangle ($;@) {
	my ($self,%attrs)=@_;
        return $self->tag('rect',%attrs);
}

*rect=\&rectangle;

=pod

=head2 image

=item  $tag = $svg->image(%attributes)

Draw an image at (x,y) with width 'width' and height 'height' linked to image
resource '-href'. See also C<use>.

B<Example:>

    $tag = $svg->image(
        x=>100, y=>100,
        width=>300, height=>200,
        '-href'=>"image.png", #may also embed SVG, e.g. "image.svg"
        id=>'image_1'
    );

B<Output:>

    <image xlink:href="image.png" x="100" y="100" width="300" height="200"/>

=cut

sub image ($;@) {
    my ($self,%attrs)=@_;
    my $im=$self->tag('image',%attrs);
    $im->{'xlink:href'}=$attrs{-href} if(defined $attrs{-href});
    return $im;
}

=pod

=head2 use

=item $tag = $svg->use(%attributes)

Retrieve the content from an entity within an SVG document and apply it at
(x,y) with width 'width' and height 'height' linked to image resource '-href'.

B<Example:>

    $tag = $svg->use(
        x=>100, y=>100,
        width=>300, height=>200,
        '-href'=>"pic.svg#image_1",
        id=>'image_1'
    );

B<Output:>

    <use xlink:href="pic.svg#image_1" x="100" y="100" width="300" height="200"/>

According to the SVG specification, the 'use' element in SVG can point to a
single element within an external SVG file.

=cut

sub use ($;@) {
    my ($self,%attrs)=@_;
    my $u=$self->tag('use',%attrs);
    $u->{'xlink:href'}=$attrs{-href} if(defined $attrs{-href});
    return $u;
}

=pod

=head2 polygon

=item $tag = $svg->polygon(%attributes)

Draw an n-sided polygon with vertices at points defined by a string of the form
'x1,y1,x2,y2,x3,y3,... xy,yn'. The C<get_path> method is provided as a
convenience to generate a suitable string from coordinate data.

B<Example:>

    # a five-sided polygon
    my $xv = [0,2,4,5,1];
    my $yv = [0,0,2,7,5];

    $points = $a->get_path(
        x=>$xv, y=>$yv,
        -type=>'polygon'
    );

    $c = $a->polygon(
        %$points,
        id=>'pgon1',
        style=>\%polygon_style
    );

SEE ALSO:

    C<polyline>, C<path>, C<get_path>.

=cut

sub polygon {
	my ($self,%attrs)=@_;
	my $polygon=$self->tag('polygon',%attrs);
	return($polygon);
}

=pod

=head2 polyline

=item $tag = $svg->polyline(%attributes)

Draw an n-point polyline with points defined by a string of the form
'x1,y1,x2,y2,x3,y3,... xy,yn'. The C<get_path> method is provided as a
convenience to generate a suitable string from coordinate data.

B<Example:>

    # a 10-pointsaw-tooth pattern
    my $xv = [0,1,2,3,4,5,6,7,8,9];
    my $yv = [0,1,0,1,0,1,0,1,0,1];

    $points = $a->get_path(
        x=>$xv, y=>$yv,
        -type=>'polyline',
        -closed=>'true' #specify that the polyline is closed.
    );

    my $tag = $a->polyline (
        %$points,
        id=>'pline_1',
        style=>{
            'fill-opacity'=>0,
            'stroke-color'=>'rgb(250,123,23)'
        }
    );

=cut

sub polyline ($;@) {
    my ($self,%attrs)=@_;
    return $self->tag('polyline',%attrs);
}

=pod

=head2 line

=item $tag = $svg->line(%attributes)

Draw a straight line between two points (x1,y1) and (x2,y2).

B<Example:>

    my $tag = $svg->line(
        id=>'l1',
        x1=>0, y1=>10,
        x2=>10, y2=>0
    );

To draw multiple connected lines, use C<polyline>.

=cut

sub line ($;@) {
    my ($self,%attrs)=@_;
    return $self->tag('line',%attrs);
}

=pod

=head2 text

=item $text = $svg->text(%attributes)->cdata();

=item $text = $svg->text(%attributes,-cdata=>'textstring');

define the container for a text string to be drawn in the image.

B<Example:>

    my $text1 = $svg->text(
        id=>'l1', x=>10, y=>10
    )->cdata('hello, world');

    my $text2 = $svg->text(id=>'l1', x=>10, y=>10, -cdata=>'hello, world');


SEE ALSO:

    C<desc>, C<cdata>.

=cut

sub text ($;@) {
    my ($self,%attrs)=@_;
    my $text=$self->tag('text',%attrs);
    return($text);
}

=pod

=head2 title

=item $tag = $svg->title(%attributes)

Generate the title of the image.

B<Example:>

    my $tag = $svg->title(id=>'root-title')->cdata('This is the title');

=cut

sub title ($;@) {
    my ($self,%attrs)=@_;
    return $self->tag('title',%attrs);
}

=pod

=head2 desc

=item $tag = $svg->desc(%attributes)

Generate the description of the image.

B<Example:>

    my $tag = $svg->desc(id=>'root-desc')->cdata('This is a description');

=cut

sub desc ($;@) {
    my ($self,%attrs)=@_;
    return $self->tag('desc',%attrs);
}

=pod

=head2 script

=item $tag = $svg->script(%attributes)

Generate a script container for dynamic (client-side) scripting using
ECMAscript, Javascript or other compatible scripting language.

B<Example:>

    my $tag = $svg->script(-type=>"text/ecmascript");

    # populate the script tag with cdata
    # be careful to manage the javascript line ends.
    # qq|text| or qq§text§ where text is the script 
    # works well for this.

    $tag->cdata(qq|function d(){
        //simple display function
        for(cnt = 0; cnt < d.length; cnt++)
            document.write(d[cnt]);//end for loop
        document.write("<BR>");//write a line break
      }|
    );

=cut

sub script ($;@) {
    my ($self,%attrs)=@_;
    return $self->tag('text',%attrs);
}

=pod

=head2 path

=item $tag = $svg->path(%attributes)

Draw a path element. The path vertices may be imputed as a parameter or
calculated usingthe C<get_path> method.

B<Example:>

    # a 10-pointsaw-tooth pattern drawn with a path definition
    my $xv = [0,1,2,3,4,5,6,7,8,9];
    my $yv = [0,1,0,1,0,1,0,1,0,1];

    $points = $a->get_path(
        x => $xv,
        y => $yv,
        -type   => 'path',
        -closed => 'true'  #specify that the polyline is closed
    );

    $tag = $svg->path(
        %$points,
        id    => 'pline_1',
        style => {
            'fill-opacity' => 0,
            'fill-color'   => 'green',
            'stroke-color' => 'rgb(250,123,23)'
        }
    );


SEE ALSO:

    L<get_path>.

=cut

sub path ($;@) {
    my ($self,%attrs)=@_;
    return $self->tag('path',%attrs);
}

=pod

=head2 get_path

=item $path = $svg->get_path(%attributes)

Returns the text string of points correctly formatted to be incorporated into
the multi-point SVG drawing object definitions (path, polyline, polygon)

B<Input:> attributes including:

    -type     = path type (path | polyline | polygon)
    x         = reference to array of x coordinates
    y         = reference to array of y coordinates

B<Output:> a hash reference consisting of the following key-value pair:

    points    = the appropriate points-definition string
    -type     = path|polygon|polyline
    -relative = 1 (define relative position rather than absolute position)
    -closed   = 1 (close the curve - path and polygon only)

B<Example:>

    #generate an open path definition for a path.
    my ($points,$p);
    $points = $svg->get_path(x=&gt\@x,y=&gt\@y,-relative=&gt1,-type=&gt'path');
 
    #add the path to the SVG document
    my $p = $svg->path(%$path, style=>\%style_definition);

    #generate an closed path definition for a a polyline.
    $points = $svg->get_path(
        x=>\@x,
        y=>\@y,
        -relative=>1,
        -type=>'polyline',
        -closed=>1
    ); # generate a closed path definition for a polyline

    # add the polyline to the SVG document
    $p = $svg->polyline(%$points, id=>'pline1');

B<Aliases:> get_path set_path

=cut

sub get_path ($;@) {
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
            $char = ' l ' if (defined $attrs{-relative}
                                && lc($attrs{-relative}));
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
    my %out = (points=>$points);
    return \%out;
}

sub make_path ($;@) {
    my ($self,%attrs) = @_;
    return get_path(%attrs);
}

sub set_path ($;@) {
    my ($self,%attrs) = @_;
    return get_path(%attrs);
}

=pod

=head2 animate

=item animate(%attributes)

Generate an SMIL animation tag. This is allowed within any nonempty tag. Refer\
to the W3C for detailed information on the subtleties of the animate SMIL
commands.

B<Inputs:> -method = Transform | Motion | Color

=cut

sub animate ($;@) {
    my ($self,%attrs) = @_;
    my %rtr = %attrs;
    my $method = $rtr{'-method'}; # Set | Transform | Motion | Color

    $method = lc($method);

    # we do not want this to pollute the generation of the tag
    delete $rtr{-method};  #bug report from briac.

    my %animation_method = (
        transform=>'animateTransform',
        motion=>'animateMotion',
        color=>'animateColor',
        set=>'set'
    );
	
    my $name = $animation_method{$method} || 'simple';
	
    #list oflegal entities for each of the 5 methods of animations
    my %legal = (
        simple =>	
          qq§ begin dur  end  min  max  restart  repeatCount 
              repeatDur  fill  attributeType attributeName additive
              accumulate calcMode  values  keyTimes  keySplines
              from  to  by §,
        animateTransform =>	
          qq§ begin dur  end  min  max  restart  repeatCount
              repeatDur  fill  additive  accumulate calcMode  values
              keyTimes  keySplines  from  to  by calcMode path keyPoints
              rotate origin type §,
	animateMotion =>	
          qq§ begin dur  end  min  max  restart  repeatCount
              repeatDur  fill  additive  accumulate calcMode  values
              to  by keyTimes keySplines  from  path  keyPoints
              rotate  origin §,
        animateColor =>	
          qq§ begin dur  end  min  max  restart  repeatCount
              repeatDur  fill  additive  accumulate calcMode  values
              keyTimes  keySplines  from  to  by §,
        set =>	
          qq§ begin dur  end  min  max  restart  repeatCount  repeatDur
              fill to §
    );

    foreach my $k (keys %rtr) {
        if ($legal{$name} !~ /$k/gs) {
            $self->{errors}{"$name.$k"} = 'Illegal animation command';
        }
    }

    return $self->tag($name,%rtr);
}

=pod

=head2 group

=item $tag = $svg->group(%attributes)

Define a group of objects with common properties. groups can have style,
animation, filters, transformations, and mouse actions assigned to them.

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

sub group ($;@) {
    my ($self,%attrs)=@_;
    return $self->tag('g',%attrs);
}

=pod

=head2 defs

=item $tag = $svg->defs(%attributes)

define a definition segment. A Defs requires children when defined using SVG.pm
B<Example:>

    $tag = $svg->defs(id  =>  'def_con_one',);

=cut

sub defs ($;@) {
    my ($self,%attrs)=@_;
    return $self->tag('defs',%attrs);
}

=pod

=head2 style

=item $svg->style(%styledef)

Sets/Adds style-definition for the following objects being created.

Style definitions apply to an object and all its children for all properties for
which the value of the property is not redefined by the child.

=cut

sub style ($;@) {
    my ($self,%attrs)=@_;

    $self->{style}=$self->{style} || {};
    foreach my $k (keys %attrs) {
        $self->{style}->{$k}=$attrs{$k};
    }

    return $self;
}

=pod

=head2 mouseaction

=item $svg->mouseaction(%attributes)

Sets/Adds mouse action definitions for tag

=cut

sub mouseaction ($;@) {
    my ($self,%attrs)=@_;

    $self->{mouseaction}=$self->{mouseaction} || {};
    foreach my $k (keys %attrs) {
        $self->{mouseaction}->{$k}=$attrs{$k};
    }

    return $self;
}

=pod

=item $svg->attrib($name, $value)

Sets/Adds mouse action definitions.

=item $svg->attrib $name, $value

=item $svg->attrib $name, \@value

=item $svg->attrib $name, \%value

Sets/Replaces attributes for a tag.

=cut

sub attrib ($$$) {
    my ($self,$name,$val)=@_;
    $self->{$name}=$val;
    return $self;
}

=pod

=head2 cdata

=item $svg->cdata($text)

Sets cdata to $text. SVG.pm allows you to set cdata for any tag. If the tag is
meant to be an empty tag, SVG.pm will not complain, but the rendering agent will
fail. In the SVG DTD, cdata is generally only meant for adding text or script
content.

B<Example:>

    $svg->text(
        style => {
            'font'      => 'Arial',
            'font-size' => 20
        })->cdata('SVG.pm is a perl module on CPAN!');

    my $text = $svg->text(style=>{'font'=>'Arial','font-size'=>20});
    $text->cdata('SVG.pm is a perl module on CPAN!');


B<Result:>

    E<lt>text style="font: Arial; font-size: 20" E<gt>SVG.pm is a perl module on CPAN!E<lt>/text E<gt>

SEE ALSO:

  C<desc>, C<title>, C<text>, C<script>.

=cut

sub cdata ($@) {
    my ($self,@txt)=@_;
    $self->{-cdata}=join(' ',@txt);
    return($self);
}

=pod

=head2 filter

=item $tag = $svg->filter(%attributes)

Generate a filter. Filter elements contain L<fe> filter sub-elements.

B<Example:>

    my $filter = $svg->filter(
        filterUnits=>"objectBoundingBox",
        x=>"-10%",
        y=>"-10%",
        width=>"150%",
        height=>"150%",
        filterUnits=>'objectBoundingBox'
    );

    $filter->fe();

SEE ALSO:

    C<fe>.

=cut

sub filter ($;@) {
    my ($self,%attrs)=@_;
    return $self->tag('filter',%attrs);
}

=pod

=head2 fe

=item $tag = $svg->fe(-type=>'type', %attributes)

Generate a filter sub-element. Must be a child of a C<filter> element.

B<Example:>

    my $fe = $svg->fe(
        -type     => 'DiffuseLighting'  # required - element name omiting 'fe'
        id        => 'filter_1',
        style     => {
            'font'      => [ qw(Arial Helvetica sans) ],
            'font-size' => 10,
            'fill'      => 'red',
        },
        transform => 'rotate(-45)'
    );

Note that the following filter elements are currently supported:

=over

=item * feBlend 

=item * feColorMatrix 

=item * feComponentTransfer 

=item * feComposite

=item * feConvolveMatrix 

=item * feDiffuseLighting 

=item * feDisplacementMap 

=item * feDistantLight 

=item * feFlood 

=item * feFuncA 

=item * feFuncB 

=item * feFuncG 

=item * feFuncR 

=item * feGaussianBlur 

=item * feImage 

=item * feMerge 

=item * feMergeNode 

=item * feMorphology 

=item * feOffset 

=item * fePointLight

=item * feSpecularLighting 

=item * feSpotLight 

=item * feTile 

=item * feTurbulence 

=back

SEE ALSO:

   C<filter>.

=cut

sub fe ($;@) {
    my ($self,%attrs) = @_;

    return 0 unless  ($attrs{'-type'});
    my %allowed = (
        blend => 'feBlend',
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
        turbulence => 'feTurbulence'
    );

    my $key = lc($attrs{'-type'});
    my $fe_name = $allowed{$key} || 'error:illegal_filter_element';
    delete $attrs{'-type'};

    return $self->tag($fe_name, %attrs);
}

=pod

=head2 pattern

=item $tag = $svg->pattern(%attributes)

Define a pattern for later reference by url.

B<Example:>

    my $pattern = $svg->pattern(
        id     => "Argyle_1",
        width  => "50",
        height => "50",
        patternUnits        => "userSpaceOnUse",
        patternContentUnits => "userSpaceOnUse"
    );

=cut

sub pattern ($;@) {
    my ($self,%attrs)=@_;
    return $self->tag('pattern',%attrs);
}

=pod

=head2 set

=item $tag = $svg->set(%attributes)

Set a definition for an SVG object in one section, to be referenced in other
sections as needed.

B<Example:>

    my $set = $svg->set(
        id     => "Argyle_1",
        width  => "50",
        height => "50",
        patternUnits        => "userSpaceOnUse",
        patternContentUnits => "userSpaceOnUse"
    );

=cut

sub set ($;@) {
    my ($self,%attrs)=@_;
    return $self->tag('set',%attrs);
}

=pod

=head2 stop

=item $tag = $svg->stop(%attributes)

Define a stop boundary for C<gradients>

B<Example:>

   my $pattern = $svg->stop(
       id     => "Argyle_1",
       width  => "50",
       height => "50",
       patternUnits        => "userSpaceOnUse",
       patternContentUnits => "userSpaceOnUse"
   );

=cut

sub stop ($;@) {
    my ($self,%attrs)=@_;
    return $self->tag('stop',%attrs);
}

=pod

=item $tag = $svg->gradient(%attributes)

Define a color gradient. Can be of type B<linear> or B<radial>

B<Example:>

    my $gradient = $svg->gradient(
        -type => "linear",
        id    => "gradient_1"
    );

=back

=cut

sub gradient ($;@) {
    my ($self,%attrs)=@_;

    my $type = $attrs{'-type'} || 'linear';
    unless ($type =~ /^(linear|radial)$/) {
        $type = 'linear';
    }
    delete $attrs{'-type'};

    return $self->tag($type.'Gradient',%attrs);
}

=pod

=head1 TO DO

The following elements have not yet been implemented as of this release:

=over

=item * altGlyph

=item * altGlyphDef

=item * altGlyphItem

=item * clipPath

=item * color-profile

=item * cursor

=item * definition-src

=item * font-face-format

=item * font-face-name

=item * font-face-src

=item * font-face-url

=item * foreignObject

=item * glyph

=item * glyphRef

=item * hkern

=item * marker

=item * mask

=item * metadata

=item * missing-glyph

=item * mpath

=item * pattern

=item * switch

=item * symbol

=item * textPath

=item * tref

=item * tspan

=item * view

=item * vkern

Although these elements do not have an explicit constructor, they can be
constructed using the generic element constructor C<tag>.

=cut

#-------------------------------------------------------------------------------

sub AUTOLOAD {
    my($class,$sub)=($AUTOLOAD=~/(.*)::([^:]+)$/);
    my $self=shift;

    ##	print STDERR qq(Undefined call to class='$class' sub='$sub' vars=').join(',',@_).qq('\n);
    if($sub eq 'something') {
    } elsif($sub eq 'DESTROY') {
        $self->release;
    } else {
        $self->{$sub}=$_[0];
    }

    return $self;
}

#-------------------------------------------------------------------------------

1;



__END__

<<<
* Is it necessary to specify an id? Required if needed for reference
  (e.g. use tag) 
  -Not necessary. id is not a required element. 
* Can a style be specified for anything? Some examples have one, some don't
  -Almost anything.
* How about letting get_path accept a hash of coordinates, too?
  -good idea.
* Can I add more than one object to an anchor, or only one?
  -more than one. There is no limit to how many as the anchor is a non-empty tag.
* How do I repeat a drawn element? Do I clone it? Clone method?
  -you invoke a new draw element. each time it's an individual element
* I don't like 'xmlify' as a method name. I would prefer 'render' or 'toxml'
  -i agree. was thinking of using render.
* We need an SVG::Parser class, don't we? (turn SVG documents into SVG objects)
  -i'll be working on that yet.
* SVG::Compress ( subclass, uses Perl GZ module, provides $svg->gzxmlify )
  -am looking for that.
* I feel that the aspect of stand-alone vs in-line is a rendering one, not an
  aspect of the SVG elements themselves.
  -well, that's the way it's implemented, isn't it?
* What's up with that AUTOLOAD method?
<<<
