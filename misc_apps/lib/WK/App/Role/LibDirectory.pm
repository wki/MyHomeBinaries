package WK::App::Role::LibDirectory;
use Moose::Role;
use File::Temp ();
use WK::Types::PathClass 'ExistingDir';

with 'MooseX::Getopt';

has directory => (
    traits => ['Getopt'],
    is => 'ro',
    isa => ExistingDir,
    required => 1,
    lazy_build => 1,
    coerce => 1,
    cmd_aliases => 'd',
    documentation => 'directory to build into, defaults to a temp dir',
);

sub _build_directory {
    my $self = shift;

    File::Temp::tempdir(CLEANUP => 1);
}

sub lib_directory { $_[0]->directory->subdir('lib/perl5') }
sub bin_directory { $_[0]->directory->subdir('bin') }

no Moose::Role;
1;
