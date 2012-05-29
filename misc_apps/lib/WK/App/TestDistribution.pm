package WK::App::TestDistribution;
use Modern::Perl;
use Moose;
use WK::Types::PathClass qw(DistributionDir ExecutableFile);
use File::Temp ();
use namespace::autoclean;

extends 'WK::App';
with 'MooseX::Getopt',
     'WK::App::Role::Cpanm',
     'WK::App::Role::LocateBinary';

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
    documentation => 'Perl binary to use for testing [$PATH/perl]',
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
    documentation => 'additional environment variables to set',
);

sub _build_perl  { $_[0]->locate_binary('perl') }
sub _build_shell { $ENV{SHELL} }

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
        "${\$self->get_cpanm_commandline} --installdeps .",
        "${\$self->perl} Makefile.PL",
        "make test",
    );
    
    $self->log_dryrun(join "\n", 'would execute:', @commands) and return;

    my $status =
        system $self->shell,
            -c => join(' && ', @commands) . ' 2>&1';

    $self->log('Status', $status >> 8);

    die 'FAIL' if $status>>8;
}

__PACKAGE__->meta->make_immutable;

1;
