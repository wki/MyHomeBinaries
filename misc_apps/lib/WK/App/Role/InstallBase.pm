package WK::App::Role::InstallBase;
use Moose::Role;
use File::Temp ();
use WK::Types::PathClass 'ExistingDir';

with 'MooseX::Getopt';

has install_base => (
    traits => ['Getopt'],
    is => 'ro',
    isa => ExistingDir,
    required => 1,
    lazy_build => 1,
    coerce => 1,
    cmd_aliases => 'L',
    documentation => 'directory to install into, defaults to a temp dir',
);

sub _build_install_base {
    my $self = shift;

    File::Temp::tempdir(CLEANUP => 1);
}

sub lib_directory { $_[0]->install_base->subdir('lib/perl5') }
sub bin_directory { $_[0]->install_base->subdir('bin') }

no Moose::Role;
1;
