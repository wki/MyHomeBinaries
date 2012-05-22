package WK::App::TestDistribution;
use Modern::Perl;
use Moose;
use MooseX::Types::Path::Class qw(File Dir);
use File::Temp ();
use autodie ':all';
use namespace::autoclean;

extends 'WK::App';
with 'MooseX::Getopt',
     'WK::App::Role::LibDirectory';

has distribution_dir => (
    traits => ['Getopt'],
    is => 'ro',
    isa => Dir,
    coerce => 1,
    required => 1,
    cmd_aliases => 'D',
    documentation => 'Directory of the distribution to test',
);

has perl_version => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Str',
    required => 1,
    cmd_aliases => 'p',
    documentation => 'Perl version to use for testing',
);

sub run {
    my $self = shift;
    
    # -- only if DIST-ZILLA:
    # chdir $self->distribution_dir
    # dzil clean
    # dzil build
    #
    # new shell, perlbrew use $self->perl_version
    # chdir $self->distribution_dir->subdir(dist_name . version);
    # cpanm -L $self->directory --installdeps .
    # PERL5LIB=$self->lib_directory make test
    # die on non-zero exit status
}

__PACKAGE__->meta->make_immutable;

1;
