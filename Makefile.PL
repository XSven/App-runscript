use strict;
use warnings;

use ExtUtils::MakeMaker qw( WriteMakefile );

my %WriteMakefileArgs = (
  NAME          => 'App::runscript',
  VERSION_FROM  => 'lib/App/runscript.pm',
  ABSTRACT_FROM => 'lib/App/runscript.pod',
  EXE_FILES     => [ qw( bin/runscript ) ],
  NO_PERLLOCAL  => 1,
  clean         => { FILES                => 'App-runscript-* cover_db' },
  dist          => { COMPRESS             => 'gzip -9f', SUFFIX => 'gz', },
  realclean     => { FILES                => 'local' },
  test          => { RECURSIVE_TEST_FILES => 1 },
);

WriteMakefile( %WriteMakefileArgs );
