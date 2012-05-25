package WK::App::TestDistribution;
use Modern::Perl;
use Moose;
use WK::Types::PathClass qw(DistributionDir ExecutableFile);
use File::Temp ();
use namespace::autoclean;

extends 'WK::App';
with 'MooseX::Getopt',
     'WK::App::Role::InstallBase';

has distribution_dir => (
    traits => ['Getopt'],
    is => 'ro',
    isa => DistributionDir,
    coerce => 1,
    required => 1,
    cmd_aliases => 'D',
    documentation => 'Directory of the distribution to test',
);

has perl => (
    traits => ['Getopt'],
    is => 'ro',
    isa => ExecutableFile,
    coerce => 1,
    required => 1,
    lazy_build => 1,
    documentation => "Perl binary to use for testing [${\(__search_in_path('perl') || 'unknown')}]",
);

has cpanm => (
    traits => ['Getopt'],
    is => 'ro',
    isa => ExecutableFile,
    coerce => 1,
    required => 1,
    lazy_build => 1,
    documentation => "cpanm binary to use for testing [${\(__search_in_path('cpanm') || 'unknown')}]",
);

has shell => (
    traits => ['Getopt'],
    is => 'ro',
    isa => ExecutableFile,
    coerce => 1,
    required => 1,
    lazy_build => 1,
    documentation => "Shell to use [$ENV{SHELL}]",
);

has env => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);

sub _build_perl  { __search_in_path('perl') }
sub _build_cpanm { __search_in_path('cpanm') }
sub _build_shell { $ENV{SHELL} }

sub __search_in_path {
    my $executable = shift;

    my ($bin) =
        map { my $bin = "$_/$executable"; -x $bin ? $bin : () }
        split ':', $ENV{PATH};

    return $bin;
}

# for performance start with:
# PERL_CPANM_OPT="--mirror /path/to/minicpan --mirror-only"
# or define in env
#
sub run {
    my $self = shift;

    $self->log("Installing modules into ${\$self->install_base}");
    $self->log("using perl ${\$self->perl}");
    $self->log("and cpanm ${\$self->cpanm}");

    $self->log('ENV:',
               map { "$_='${\$self->env->{$_}}'" }
               keys %{$self->env})
        if scalar keys %{$self->env};

    my @commands = (
        ( map { "export $_='${\$self->env->{$_}}'"} keys %{$self->env} ),
        "export PATH='${\$self->perl->dir}:$ENV{PATH}'",
        "export PERL5LIB='${\$self->lib_directory}'",
        "cd '${\$self->distribution_dir}' ",
        "${\$self->cpanm} -L '${\$self->install_base}' -q -n --installdeps . ",
        "${\$self->perl} Makefile.PL",
        "make test",
    );

    my $status =
        system $self->shell,
            -c => join(' && ', @commands) . ' 2>&1';

    $self->log('Status', $status >> 8);

    die 'FAIL' if $status>>8;
}

__PACKAGE__->meta->make_immutable;

1;
