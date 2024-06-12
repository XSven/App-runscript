use strict;
use warnings;

use Test::More import => [ qw( is is_deeply like pass plan subtest ) ], tests => 5;
use Test::Fatal qw( exception );

use File::Basename qw( basename );
use File::Spec     ();
use Sub::Override  ();

use App::runscript ();

like exception {
  App::runscript::_prepend_library_path( File::Spec->catfile( $ENV{ PWD }, qw( bin runscript ) ) )
},
  qr/has no execute permission/,
  'script has no execute permission';

like exception { App::runscript::_prepend_library_path( 'baz.pl' ) }, qr/\ACannot find script/, 'script is not in PATH';

{
  my $override = Sub::Override->new( 'App::runscript::_which' => sub ( $;$ ) { '/foo/bar/baz.pl' } );
  like exception { App::runscript::_prepend_library_path( 'baz.pl' ) }, qr/\ABasename of '\/foo\/bar' is not 'bin'/,
    'script is not in bin directory';
}

like exception { App::runscript::_prepend_library_path( App::runscript::_which( 'perl', 1 ) ) }, qr/\ALibrary path/,
  'library path does not exist';

subtest 'successfull execution' => sub {
  plan tests => 5;

  my $expected_script = '/foo/bin/baz.pl';
  my $expected_args   = [ qw( arg1 arg2 ) ];
  my $override        = Sub::Override->new->override(
    'App::runscript::_which' => sub ( $;$ ) { pass( 'mocked _which() called once' ); return $expected_script } )
    ->override( 'App::runscript::_is_dir' => sub ( $ ) { pass( 'mocked _is_dir() called once' ); return 1 } );

  my @got = App::runscript::_prepend_library_path( basename( $expected_script ), @$expected_args );
  is $got[ 0 ], '-I/foo/lib/perl5', 'check library path passed to -I option';
  is $got[ 1 ], $expected_script,   'check absolute path of script';
  is_deeply [ @got[ 2 .. 3 ] ], $expected_args, 'check arguments passed to script';
};
