=pod

=head1 NAME

SVG::XML - Handle the XML generation bits for SVG.pm

=head1 AUTHOR

Ronan Oger, ronan@roasp.com

=head1 SEE ALSO

perl(1),L<SVG>,L<SVG::Element>
http://roasp.com/
http://www.w3c.org/Graphics/SVG/

=cut

package SVG::XML;
use strict;
use vars qw($VERSION @ISA @EXPORT );

$VERSION = "1.0";

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	xmlescp
	cssstyle
	xmlattrib
 	xmlcomment
 	xmlpi
	xmltag
	xmltagopen
	xmltagclose
	xmltag_ln
	xmltagopen_ln
	xmltagclose_ln
	processtag
	xmldecl
	dtddecl
);

sub xmlescp ($) {
    my $s=shift;

    $s = '0' unless defined $s;
    $s=join(', ',@{$s}) if(ref($s) eq 'ARRAY');
    $s=~s/&/&amp;/cg;
    $s=~s/>/&gt;/cg;
    $s=~s/</&lt;/cg;
    $s=~s/\"/&quot;/cg;
    $s=~s/\'/&apos;/cg;
    $s=~s/\`/&apos;/cg;
    $s=~s/([\x00-\x1f])/sprintf('&#x%02X;',chr($1))/cg;

    return $s;
}

sub cssstyle {
    my %attrs=@_;
    return(join('; ',map { qq($_: ).$attrs{$_} } keys(%attrs)));
}

sub xmlattrib {
    my %attrs=@_;
    return(join(' ',map { qq($_=").$attrs{$_}.q(") } keys(%attrs)));
}

sub xmltag ($$;@) {
    my ($name,$ns,%attrs)=@_;
    $ns=$ns?"$ns:":'';
    my $at=' '.xmlattrib(%attrs)||'';
    return qq(<$ns$name$at />);
}

sub xmltag_ln ($$;@) {
    my ($name,$ns,%attrs)=@_;
    return xmltag($name,$ns,%attrs).qq(\n);
}

sub xmltagopen ($$;@) {
    my ($name,$ns,%attrs)=@_;
    $ns=$ns?"$ns:":'';
    my $at=' '.xmlattrib(%attrs)||'';
    return qq(<$ns$name$at>);
}

sub xmltagopen_ln ($$;@) {
    my ($name,$ns,%attrs)=@_;
    return xmltagopen($name,$ns,%attrs).qq(\n);
}

sub xmlcomment ($$) {
    my ($self,$r_comment) = @_;
    my $ind = "\n".$self->{-indent} x $self->{-level};
    return(join($ind,map { qq(<!-- $_ -->)} @$r_comment)."\n");
}

sub xmlpi ($$) {
    my ($self,$r_pi) = @_;
    my $ind = "\n".$self->{-indent} x $self->{-level};
    return(join($ind,map { qq(<?$_?>)} @$r_pi)."\n");
}

*processinginstruction=\&xmlpi;

sub xmltagclose ($$) {
    my ($name,$ns)=@_;
    $ns=$ns?"$ns:":'';
    return qq(</$ns$name>);
}

sub xmltagclose_ln ($$) {
    my ($name,$ns)=@_;
    return xmltagclose($name,$ns).qq(\n);
}

sub dtddecl ($) {
    my $self        = shift;
    my $docroot      = $self->{-docroot} || 'svg';
    my $id;
    if ($self->{-pubid}) {
      $id  = ' PUBLIC "'.$self->{-pubid}.'"';
      $id .= ' "'.$self->{-sysid}.'" ' if ($self->{-sysid});
    } elsif ($self->{-sysid}) {
      $id      = ' SYSTEM "'.$self->{-sysid}.'"';
    } else { $id =  ' PUBLIC "-//W3C//DTD SVG 1.0//EN"'."\n\t\t".  '"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd"'}

    my $extension = '';
    $extension  = "\n[\n$self->{-extension}\n]\n" if ($self->{-extension});
    my $at=join(' ',($docroot, $id));
    
    return qq(<!DOCTYPE $at $extension>\n);
}

sub xmldecl ($) {
    my $self = shift;
    my $version    = $self->{-version} || '1.0';
    my $encoding   = $self->{-encoding} || 'UTF-8';
    my $standalone = $self->{-standalone} ||'yes';
    my $ns         = $self->{-namespace} || 'svg';
    return qq§<?xml version="$version" encoding="$encoding" standalone="$standalone"?>§. "\n";

}

#-------------------------------------------------------------------------------

1;
