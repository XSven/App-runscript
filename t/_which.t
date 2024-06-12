use strict;
use warnings;

use Test::More import => [ qw( is like ) ], tests => 4;
use Test::Fatal qw( exception );

use App::runscript();

like exception { App::runscript::_which( undef ) }, qr/\ACannot locate undefined executable file/,
  'executable is undefined';

is App::runscript::_which( 'perl' ), $^X, 'locate perl';

like App::runscript::_which( 'perl', 1 ), qr/perl\z/, 'locate perl returning absolute path';

{
  local $ENV{ PATH } = "./bin:$ENV{PATH}";
  is App::runscript::_which( 'runscript' ), undef, 'runscript has no execute permissions';
}
