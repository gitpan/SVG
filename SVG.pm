=pod 

=head1 NAME

SVG - Perl extension for generating Scalable Vector Graphics (SVG) documents

=cut

package SVG;
use strict;

use vars qw($VERSION @ISA $AUTOLOAD);
use Exporter;
use SVG::XML;
use SVG::Element;
@ISA = qw(SVG::Element Exporter);

$VERSION = "2.0";

#-------------------------------------------------------------------------------

=pod 

=head2 VERSION

Version 1.12, 18 October 2001

=head1 METHODS

L<"animate">, L<"cdata">, L<"circle">, L<"defs">, L<"desc">,
L<"ellipse">, L<"fe">, L<"get_path">, L<"group">, L<"image">, L<"line">,
L<"mouseaction">, L<"new">, L<"path">, L<"polygon">, L<"polyline">, L<"rectangle (alias: rect)">, L<"script">,
L<"style">, L<"text">, L<"title">, L<"use">, L<"xmlify (alias: to_xml render)">

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
        -namespace => "svg",
        -pubid => "-//W3C//DTD SVG 1.0//EN",
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

=item 1 The first step is to construct a new SVG object with L<"new">.

=item 2 The second step is to call element constructors to create SVG elements.
Examples of element constructors are L<"circle"> and L<"path">.

=item 3 The third and last step is to render the SVG object into XML using the
L<"xmlify"> method.

=back

The L<"xmlify"> method takes a number of optional arguments that control how SVG
renders the object into XML, and in particular determine whether a stand-alone
SVG document or an inline SVG document fragment is generated:

=over (

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

None. However, SVG permits both options and additional element methods to be
specified in the import list. These options and elements are then available
for all SVG instances that are created with the L<"new"> constructor. For example,
to change the indent string to two spaces per level:

    use SVG qw(-indent => "  ");

With the exception of -auto, all options may also be specified to the L<"new">
constructor. The currently supported options are:

    -auto        enable autoloading of all unrecognised method calls (0)
    -indent      the indent to use when rendering the SVG into XML ("\t")
    -inline      whether the SVG is to be standalone or inlined (0)
    -printerror  print SVG generation errors to standard error (1)
    -raiseerror  die if a generation error is encountered (1)
    -nostub      only return the handle to a blank SVG document without any elements

SVG also allows additional element generation methods to be specified in the
import list. For example to generate 'star' and 'planet' element methods:

    use SVG qw(star planet);

or:

    use SVG ("star","planet");

This will add 'star' to the list of elements supported by SVG.pm (but not of
course other SVG parsers...). Alternatively the '-auto' option will allow
any unknown method call to generate an element of the same name:

    use SVG (-auto => 1, "star", "planet");

Any elements specified explicitly (as 'star' and 'planet' are here) are
predeclared; other elements are defined as and when they are seen by Perl. Note
that enabling '-auto' effectively disables compile-time syntax checking for
valid method names.

B<Example:>

    use SVG (
        -auto       => 0,
        -indent     => "  ",
        -raiserror  => 0,
        -printerror => 1,
        "star", "planet", "moon"
    );

=head1 SEE ALSO

    perl(1), L<SVG::XML>, L<SVG::Element>, L<SVG::Parser>
    http://roasp.com/
    http://www.w3c.org/Graphics/SVG/

=head1 AUTHOR

Ronan Oger, RO IT Systemms GmbH, ronan@roasp.com

=head1 CREDITS

Peter Wainwright, peter@roasp.com Excellent ideas, beta-testing, SVG::Parser

=head1 EXAMPLES

http://roasp.com/

=cut


#-------------------------------------------------------------------------------

my %default_attrs = (
    -auto       => 0,    # permit arbitrary autoloads (only at import)
    -indent     => "\t", # what to indent with
    -inline     => 0,    # inline or stand alone
    -printerror => 1,    # print error messages to STDERR
    -raiseerror => 1,    # die on errors (implies -printerror)
    -raiseerror => 1,    # die on errors (implies -printerror)
    -raiseerror => 1,    # die on errors (implies -printerror)
    -docroot => 'svg',    # die on errors (implies -printerror)
);

sub import {
    my $package=shift;

    my $attr=undef;
    foreach (@_) {
        if ($attr) {
            $default_attrs{$attr}=$_;
            undef $attr;
        } elsif (exists $default_attrs{$_}) {
            $attr=$_;
        } else {
            /^-/ and die "Unknown attribute '$_' in import list\n";
            $SVG::Element::autosubs{$_}=1; # add to list of autoloadable tags
        }
    }

    # switch on AUTOLOADer, if asked.
    if ($default_attrs{'-auto'}) {
        *SVG::Element::AUTOLOAD=\&SVG::Element::autoload;
    }

    # predeclare any additional elements asked for by the user
    foreach my $sub (keys %SVG::Element::autosubs) {
        $SVG::Element::AUTOLOAD=("SVG::Element::$sub");
        SVG::Element::autoload();
    }

    delete $default_attrs{-auto}; # -auto is only allowed here, not in new

    return ();
}

#-------------------------------------------------------------------------------

=pod

=head1 Methods

SVG provides both explicit and generic element constructor methods. Explicit
generators are generally (with a few exceptions) named for the element they
generate. If a tag method is required for a tag containing hyphens, the method 
name replaces the hyphen with an underscore. ie: to generate tag <column-heading id="new">
you would use method $svg->column_heading(id=>'new').


All element constructors take a hash of element attributes and options;
element attributes such as 'id' or 'border' are passed by name, while options for the
method (such as the type of an element that supports multiple alternate forms)
are passed preceded by a hyphen, e.g '-type'. Both types may be freely
intermixed; see the L<"fe"> method and code examples througout the documentation
for more examples.

=head2 new (constructor)

$svg = SVG->new(%attributes)

Creates a new SVG object. Attributes of the document SVG element be passed as
an optional list of key value pairs. Additionally, SVG options (prefixed with
a hyphen) may be set on a per object basis:

B<Example:>

    my $svg1=new SVG;

    my $svg2=new SVG(id => 'document_element');

    my $svg3=new SVG(s
        -printerror => 1,
        -raiseerror => 0,
        -indent     => '  ',
        -docroot => 'svg', #default document root element (SVG specification assumes svg). Defaults to 'svg' if undefined
        -sysid      => 'abc', #optional system identifyer 
        -pubid      => "-//W3C//DTD SVG 1.0//EN", #public identifyer default value is "-//W3C//DTD SVG 1.0//EN" if undefined
        -namespace => 'mysvg',
        -inline   => 1
        id          => 'document_element',
        width       => 300,
        height      => 200,
    );

Default SVG options may also be set in the import list. See L<"EXPORTS"> above
for more on the available options. 

Furthermore, the following options:

  
    -version
    -encoding
    -standalone
    -namespace
    -inline
    -identifier
    -dtd (standalone)

may also be set in xmlify, overriding any corresponding values set in the SVG->new declaration

=cut

#-------------------------------------------------------------------------------
#
# constructor for the SVG data model.
#
# the new constructor creates a new data object with a document tag at its base.
# this document tag then has either:
#     a child entry parent with its child svg generated (when -inline = 1)
# or
#     a child entry svg created.
#
# Because the new method returns the $self reference and not the 
# latest child to be created, a hash key -document with the reference to the hash
# entry of its already-created child. hence the document object has a -document reference
# to parent or svg if inline is 1 or 0, and parent will have a -document entry
# pointing to the svg child.
#
# This way, the next tag constructor will descend the
# tree until it finds no more tags with -document, and will add
# the next tag object there.
# refer to the SVG::tag method 

sub new ($;@) {
    my ($proto,%attrs)=@_;
    my $class=ref $proto || $proto;
    my $self;

    # establish defaults for unspecified attributes
    foreach my $attr (keys %default_attrs) {
	      $attrs{$attr}=$default_attrs{$attr} 
                        unless exists $attrs{$attr}
    }
    $self = $class->SUPER::new('document');

    $self->{$_}=$attrs{$_} foreach keys %default_attrs;
    $self->{-level}=0;
    $self->{-version}   = $attrs{-version}    if ($attrs{-version});
    $self->{-extension} = $attrs{-extension}  if ($attrs{-extension});
    $self->{-encoding}  = $attrs{-encoding}   if ($attrs{-encoding});
    $self->{-standalone}= $attrs{-standalone} if ($attrs{-standalone});
    $self->{-identifier}= $attrs{-identifier} if ($attrs{-identifier});
    $self->{-dtd}       = $attrs{-dtd}        if ($attrs{-dtd});
    $self->{-namespace} = $attrs{-namespace}  if ($attrs{-namespace});
    $self->{-inline}     = $attrs{-inline}    if ($attrs{-inline});   

    # create SVG object according to inline attribute
    my $svg; 
    unless ($attrs{-nostub}) {
        $svg = $self->svg(%attrs);
        $self->{-document} = $svg;
    }
    # add -attributes to SVG object
    return $self;
}

#-------------------------------------------------------------------------------

=pod

=head2 xmlify (alias: to_xml render)

$string = $svg->xmlify(%attributes);

Returns xml representation of svg document.

B<XML Declaration>

    Name               Default Value
    -version           '1.0'               
    -encoding          'UTF-8'
    -standalone        'yes'
    -namespace         'svg'                - namespace for elements
    -inline            '0' - If '1', then this is an inline document.
    -pubid             '-//W3C//DTD SVG 1.0//EN';
    -dtd (standalone)  'http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd'

=cut 

sub xmlify ($;@) {
    my ($self,%attrs) = @_;
    my ($decl,$ns);

  foreach my $key (keys %attrs) {
    next unless ($key =~ /^\-/);
    $self->{$key} = $attrs{$key};
  }

  foreach my $key (keys %$self) {
    next unless ($key =~ /^\-/);
    $attrs{$key} ||= $self->{$key};
  }
#    return $decl.$self->SUPER::xmlify($ns);
    return $self->SUPER::xmlify($self->{-namespace});
}

*render=\&xmlify;

*to_xml=\&xmlify;
#-------------------------------------------------------------------------------

1;