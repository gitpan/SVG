package SVG::Utils;

use vars qw( @ISA @EXPORT );

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
	svgdecl
);

sub new {
	my ($class,$name,%attrs)=@_;
	my $self={};
	bless($self,$class);
	$self->{-name}=$name;
	foreach my $k (keys %attrs) {
		if($k=~/^\-/) { next; }
		$self->{$k}=$attrs{$k};
	}
	return($self);
}

sub release {
	my $self=shift @_;
	foreach my $k (keys(%{$self})) {
		if($k=~/^\-/) { next; }
		if(ref($self->{$k})=~/^SVG/) {
			eval {
				$self->{$k}->release;
			};
		}
		delete($self->{$k});
	}
	return($self);
}

sub xmlescp {
	my $s=shift @_;
	$s=join(', ',@{$s}) if(ref($s) eq 'ARRAY');
	$s=~s/&/&amp;/cg;
	$s=~s/>/&gt;/cg;
	$s=~s/</&lt;/cg;
	$s=~s/"/&quot;/cg;
	$s=~s/'/&apos;/cg;
	$s=~s/([\x00-\x1f])/sprintf('&#x%02X;',chr($1))/cg;
	return($s);
}

sub cssstyle {
	my %attrs=@_;
	return(join('; ',map { qq($_: ).xmlescp($attrs{$_}) } keys(%attrs)));
}

sub xmlattrib {
	my %attrs=@_;
	return(join(' ',map { qq($_=").xmlescp($attrs{$_}).q(") } keys(%attrs)));
}

sub xmltag {
	my ($name,%attrs)=@_;
	my $at=xmlattrib(%attrs);
	return(qq(<$name $at/>));
}

sub xmltag_ln {
	my ($name,%attrs)=@_;
	return(xmltag($name,%attrs).qq(\n));
}

sub xmltagopen {
	my ($name,%attrs)=@_;
	my $at=xmlattrib(%attrs);
	return(qq(<$name $at>));
}

sub xmltagopen_ln {
	my ($name,%attrs)=@_;
	return(xmltagopen($name,%attrs).qq(\n));
}

sub xmltagclose {
	my ($name)=@_;
	return(qq(</$name>));
}

sub xmltagclose_ln {
	my ($name,%attrs)=@_;
	return(xmltagclose($name,%attrs).qq(\n));
}

sub processtag {
	my ($name,@txt)=@_;
	my $at=join(' ',@txt);
	return(qq(<!$name $at>\n));
}

sub xmldecl {
	my ($name,%attrs)=@_;
	my $at=xmlattrib(%attrs);
	return(qq(<?$name $at?>\n));
}

sub svgdecl {
	my $decl='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'."\n";
	$decl.=processtag(
		'DOCTYPE',
		'svg',
		'PUBLIC',
		q("-//W3C//DTD SVG 20001102//EN"),
		q("http://www.w3.org/TR/2000/CR-SVG-20001102/DTD/svg-20001102.dtd")
	);
	return($decl);
}


1;

__END__
