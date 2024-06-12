use strict;
use warnings;

package App::runscript;

# keeping the following $VERSION declaration on a single line is important
#<<<
use version 0.9915; our $VERSION = version->declare( 'v1.0.0' );
#>>>

use subs qw( _croakf _is_dir _prepend_library_path _which );

use Config         qw( %Config );
use File::Basename qw( basename dirname );
use File::Spec     qw();

sub _croakf ( $@ ) {
  require Carp;
  @_ = ( ( @_ == 1 ? shift : sprintf shift, @_ ) . ', stopped' );
  goto &Carp::croak;
}


sub _is_dir ( $  ) {
  return -d $_[0]
}

sub _prepend_library_path ( @ ) {
  my ( $script ) = @_;

  if ( File::Spec->file_name_is_absolute( $script ) ) {
    _croakf "Script '%s' has no execute permission", $script unless -x $script;
  } else {
    $script = _which $script, 1;
    _croakf "Cannot find script '%s' in PATH (%s)", $_[ 0 ], $ENV{ PATH } unless defined $script;
  }
  shift;

  my $install_bin = dirname $script;
  _croakf "Basename of '%s' is not 'bin'", $install_bin unless basename( $install_bin ) eq 'bin';

  my $install_base = dirname dirname $script;
  my $install_lib  = File::Spec->catdir( $install_base, qw( lib perl5 ) );

  _croakf "Library path '%s' derived from script name '%s' does not exist", $install_lib, $script
    unless _is_dir $install_lib;

  return ( "-I$install_lib", $script, @_ );
}

sub _which ( $;$ ) {
  my ( $executable, $abs_path ) = @_;

  _croakf 'Cannot locate undefined executable file' unless defined $executable;

  # path_sep refers to the command shell search PATH separator character
  for ( split /$Config{ path_sep }/, $ENV{ PATH } ) { ## no critic (RequireExtendedFormatting)
    my $file = File::Spec->catfile( $_, $executable );
    if ( -x $file ) {
      if ( $abs_path ) {
        require Cwd;
        return Cwd::abs_path( $file );
      } else {
        return $file;
      }
    }
  }

  return;
}

1;
__END__

https://stackoverflow.com/questions/3841322/how-do-i-load-libraries-relative-to-the-script-location-in-perl

https://perldoc.perl.org/perlrun
https://perldoc.perl.org/functions/exec


https://metacpan.org/pod/Path::This
https://metacpan.org/pod/lib::relative
https://metacpan.org/pod/FindBin

https://metacpan.org/pod/lib::root
https://metacpan.org/pod/FindBin::libs
