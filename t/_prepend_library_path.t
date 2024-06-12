use strict;
use warnings;

use Test::More import => [ qw( is like ) ], tests => 4;
use Test::Fatal qw( exception );

use File::Spec    ();
use Sub::Override ();

use App::runscript ();

like exception {
  App::runscript::_prepend_library_path( File::Spec->catfile( $ENV{ PWD }, qw( bin runscript ) ) )
},
  qr/has no execute permission/,
  'script has no execute permission';

like exception { App::runscript::_prepend_library_path( 'runscript' ) }, qr/\ACannot find script/, 'script not in PATH';

like exception { App::runscript::_prepend_library_path( 'grep' ) }, qr/\ALibrary path/, 'library path does not exist';

{
  my $override = Sub::Override->new( 'App::runscript::_which' => sub ( $;$ ) { '/foo/bar/baz' } );
  like exception { App::runscript::_prepend_library_path( 'baz' ) }, qr/\ABasename of '\/foo\/bar' is not 'bin'/,
    'script not in bin directory';
}
