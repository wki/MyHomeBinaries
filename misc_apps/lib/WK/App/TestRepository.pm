package WK::App::TestRepository;
use Modern::Perl;
use Moose;
# use WK::Types::PathClass qw(DistributionDir ExecutableFile);
# use File::Temp ();
use namespace::autoclean;

extends 'WK::App';
with 'MooseX::Getopt';

# for performance start with:
# PERL_CPANM_OPT="--mirror /path/to/minicpan --mirror-only"
#
sub run {
    # for every repository:
        # fetch repository from URL into a temp_dir
        # cd temp_dir/repository
        # if dist.ini --> dzil build
        
        # for every perl version
            # next if commit already tested
            # test_distribution
            # record test results
}

__PACKAGE__->meta->make_immutable;

1;

__END__

global config file -- or commandline options
 - all perl versions to use
 - all repository URLs to test
 - env settings

