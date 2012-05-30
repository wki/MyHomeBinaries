package WK::App::Role::Cpanm;
use Moose::Role;
use File::Temp ();
use WK::Types::PathClass qw(ExistingDir ExecutableFile);

with 'MooseX::Getopt',
     'WK::App::Role::LocateBinary';

sub DEMOLISH;

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

has cpanm => (
    traits => ['Getopt'],
    is => 'ro',
    isa => ExecutableFile,
    coerce => 1,
    required => 1,
    lazy_build => 1,
    documentation => 'cpanm binary to use for testing [$PATH/cpanm]',
);

has cpanm_options => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'ArrayRef[Str]',
    required => 1,
    lazy_build => 1,
    cmd_aliases => 'o',
    documentation => 'Typical options for cpanm. ' .
                     'Uses a minicpan mirror dir at $HOME/minicpan if present',
);

# ensure we demolish early to allow testing
before DEMOLISH => sub {
    File::Temp::cleanup();
};

sub _build_install_base  { File::Temp::tempdir(CLEANUP => 1) }
sub _build_cpanm         { $_[0]->locate_binary('cpanm') }
sub _build_cpanm_options { -d "$ENV{HOME}/minicpan"
    ? ['--mirror', "$ENV{HOME}/minicpan", '--mirror-only']
    : []
}
sub lib_directory        { $_[0]->install_base->subdir('lib/perl5') }
sub bin_directory        { $_[0]->install_base->subdir('bin') }

sub run_cpanm {
    my $self = shift;
    
    system $self->get_cpanm_commandline(@_);
}

sub get_cpanm_commandline {
    my $self = shift;
    
    return 
        join ' ',
             $self->cpanm,
             @{$self->cpanm_options},
             '-n',
             '-q',
             '-L' => "'${\$self->install_base}'",
             ($self->debug ? () : '>/dev/null 2>/dev/null'),
             @_;
}

no Moose::Role;
1;
