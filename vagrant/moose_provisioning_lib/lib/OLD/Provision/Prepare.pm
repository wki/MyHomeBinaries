package Provision::Prepare;

#
# CORE modules:
#
use strict;
use warnings;
use feature ':5.10';
use FindBin;
use Cwd 'abs_path';
use File::Find;
use Module::CoreList;

#
# non-CORE, must be included.
#
use HTTP::Lite;

#
# we must ensure that we have everything we need.
# To do so, we ensure we have
#   - a working local/lib directory relative to the started script
#   - a working cpanm installer in local/bin
#   - all modules required by this set of modules installed
#

# actual commandline processing happens in Provision::App.
# just do the most interesting switches for this module
our $debug          = grep { $_ eq '--debug' } @ARGV;
our $dryrun         = grep { $_ eq '-n' } @ARGV;

our $CPAN_MIRROR    = 'http://cpan.noris.de';
our $PACKAGE_URL    = "$CPAN_MIRROR/modules/02packages.details.txt.gz";
our $AUTHOR_URL     = "$CPAN_MIRROR/authors/id";

our $root_dir       = abs_path($FindBin::Bin);
our $lib_dir        = "$root_dir/lib";
our $local_dir      = "$root_dir/local";
our $local_lib_dir  = "$local_dir/lib";
our $perl_lib_dir   = "$local_dir/lib/perl5";
our $local_bin_dir  = "$local_dir/bin";
our $cpanm          = "$local_dir/bin/cpanm";
our $local_tmp_dir  = "$local_dir/tmp";

our $packages;

sub import {
    say "Provision::Prepare, root_dir=$root_dir" if $debug;

    # FIXME: find a better way
    # create_local_dir()  if !-d $local_dir;
    # install_cpanm()     if !-x $cpanm;
    # install_missing_modules();

    eval "use lib '$perl_lib_dir'";

    say "Provision::Prepare done" if $debug;
}

sub create_local_dir {
    foreach my $dir ($local_dir, $local_lib_dir, $local_bin_dir, $local_tmp_dir) {
        say "mkdir $dir..." if $debug;

        mkdir $dir
            or die "could not create '$dir': $!";
    }
}

sub install_cpanm {
    load_package_file();

    $packages =~ m{App::cpanminus\s+([0-9.]+)\s+(M/MI/MIYAGAWA/.*?\.gz)}xms
        or die 'could not find cpanm in package list, stopping';
    my $version = $1;
    my $path = $2;
    say "CPANM: version=$version, path=$path" if $debug;

    my $tar_gz = get_via_http("$AUTHOR_URL/$path")
        or die 'could not load cpanm .tar.gz';

    write_to($tar_gz, '>', "$local_tmp_dir/cpanm.tar.gz");

    system "tar xfz $local_tmp_dir/cpanm.tar.gz -O --include '*/bin/cpanm' > $cpanm"
        and die 'could not extract .tar.gz';

    chmod 0755, $cpanm;

    say 'installed cpanm' if $debug;
}

sub install_missing_modules {
    load_package_file();

    say 'collecting  modules...' if $debug;

    my %distribution_for;
    foreach my $line (split qr{[\r\n]+}xms, $packages) {
        next if $line !~ m{\A (\S+) .*? (\S+) \s*\z}xms;
        $distribution_for{$1} = $2;
    }

    my %install_module;
    find(sub {
        return if !-f;

        my $content = read_from('<', $_);
        foreach my $module ($content =~ m{^\s* use \s+ ([\w:]+)}xmsg) {
            next if !exists $distribution_for{$module};
            $install_module{$module}++;
        }
    }, $lib_dir);

    foreach my $module (sort keys %install_module) {
        my $first_release = Module::CoreList->first_release($module)
            and next;
        say "    checking $module..." if $debug;

        eval "use $module";
        if ($@) {
            ### TODO: remove -n switch
            system "perl '$cpanm' -L '$local_dir' -n '$module' >/dev/null 2>/dev/null"
                and die "error loading module '$module'";
        } else {
            say "             $module is present" if $debug;
        }
    }
}

sub load_package_file {
    return if $packages;

    my $package_file = "$local_tmp_dir/packages.gz";

    if (!-f $package_file || -M $package_file > 1) {
        my $packages_gz = get_via_http($PACKAGE_URL);
        write_to($packages_gz, '>', "$local_tmp_dir/packages.gz");
    }
    
    ### maybe use IO::Uncompress::Gunzip [Core]

    $packages = read_from('-|', "gunzip --to-stdout '$package_file'");
}

sub write_to {
    my ($content, $mode, $file) = @_;

    open my $fh, $mode, $file
        or die "cannot open $file for writing";
    print $fh $content;
    close $fh
        or die "cannot write $file";
}

sub read_from {
    my ($mode, $file) = @_;

    local $/ = undef;

    open my $fh, $mode, $file
        or die "cannot open $file";
    my $content = <$fh>;
    close $fh
        or die "cannot read from $file";

    return $content;
}

sub get_via_http {
    my $url = shift;

    say "get_via_http: '$url'";

    my $http = HTTP::Lite->new;
    my $req = $http->request($url)
        or die "Unable to get document: $!";
    return $http->body();
}

1;
