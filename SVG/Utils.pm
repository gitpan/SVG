package SVG::Utils;
use strict;
use vars qw($VERSION @ISA @EXPORT );

$VERSION = "0.401";

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	xmlescp
	cssstyle
	xmlattrib
	xmltag
	xmltagopen
	xmltagclose
	xmltag_ln
	xmltagopen_ln
	xmltagclose_ln
	processtag
	xmldecl
	dtddecl
	parentdecl
);

#-------------------------------------------------------------------------------

sub new ($$;@) {
    my ($proto,$name,%attrs)=@_;
    my $class=ref($proto) || $proto;

    my $self={-name => $name};
    foreach my $key (keys %attrs) {
        next if $key=~/^\-/;
        $self->{$key}=$attrs{$key};
    }

    return bless($self,$class);
}

#-------------------------------------------------------------------------------

sub release ($) {
    my $self=shift;

    foreach my $key (keys(%{$self})) {
        next if $key=~/^\-/;
        if (ref($self->{$key})=~/^SVG/) {
            eval { $self->{$key}->release; };
        }
        delete($self->{$key});
    }

    return $self;
}

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
    return(join('; ',map { qq($_: ).xmlescp($attrs{$_}) } keys(%attrs)));
}

sub xmlattrib {
    my %attrs=@_;
    return(join(' ',map { qq($_=").xmlescp($attrs{$_}).q(") } keys(%attrs)));
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

sub xmltagclose ($$) {
    my ($name,$ns)=@_;
    $ns=$ns?"$ns:":'';
    return qq(</$ns$name>);
}

sub xmltagclose_ln ($$) {
    my ($name,$ns)=@_;
    return xmltagclose($name,$ns).qq(\n);
}

sub n_processtag ($;@) {
    my ($name,@txt)=@_;
    my $at=join(' ',@txt);
    return qq(<!$name $at>\n);
}

#<parent xmlns="http://example.org"
#       xmlns:svg="http://www.w3.org/2000/svg">
# process the parent tag for embedded tag

sub p_processtag ($;@) {
    my ($ns,%attrs)=@_;
    my $at=xmlattrib(%attrs);
    return qq(<parent $at>);
}

sub xmldecl ($;@) {
    my ($name,%attrs)=@_;
    my $at=xmlattrib(%attrs);
    return qq(<?$name $at?>\n);
}

sub dtddecl {
    my %attrs=@_;
    my $version     = $attrs{-version} || '1.0';
    my $encoding    = $attrs{-encoding} || 'UTF-8';
    my $standalone  = $attrs{-standalone} ||'yes';
    my $ns          = $attrs{-namespace} || '';
    my $dtd_ns = $ns || 'svg';
    my $decl=qq§<?xml version="$version" encoding="$encoding" standalone="$standalone"?>§."\n";
    my $identifier  = $attrs{-identifier} || '-//W3C//DTD SVG 1.0//EN';
    my $dtd         = $attrs{-dtd} || 
      #old dtd
      #'http://www.w3.org/TR/2000/CR-SVG-20001102/DTD/svg-20001102.dtd'; 
      'http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd';
    $decl.=n_processtag('DOCTYPE',
                        $dtd_ns,
                        'PUBLIC',
                        qq§"$identifier"§,
                        qq§"$dtd"§ );

    return ($decl,$ns);
}

sub parentdecl {
    my %attrs=@_;
    my $version    = $attrs{-version} || '1.0';
    my $encoding   = $attrs{-encoding} || 'UTF-8';
    my $standalone = $attrs{-standalone} ||'yes';
    my $ns         = $attrs{-namespace} || 'svg';
    my $decl=qq§<?xml version="$version" encoding="$encoding" standalone="$standalone"?>§."\n";
    my $xmlns      = $attrs{-xmlns} || 'http://missing.xmlns.attribute';
    my $ns_url     = $attrs{-ns_url}|| 'http://missing.ns_url.attribute';
    $decl.=p_processtag($ns,xmlns=>$xmlns,"xmlns:$ns"=>$ns_url);

    return ($decl,$ns);
}

#-------------------------------------------------------------------------------

1;
