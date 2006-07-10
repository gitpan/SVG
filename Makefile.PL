use ExtUtils::MakeMaker;
use strict;

WriteMakefile(
    'NAME'     => 'SVG2',
    'VERSION_FROM'   => 'SVG2.pm',
    'PREREQ_PM'  => {
    'Pod::Usage'         => 0,
    'XML2' => 0,
    },
    'AUTHOR'        => "Martin Owens <DoctorMO{atta}gmail.com>",
);

