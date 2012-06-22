package Provision::Prepare;
use strict;
use warnings;
use feature ':5.10';
use FindBin;
use Cwd 'abs_path';
use HTTP::Lite;  ### must be included, but is PP and only 1 File

#
# we must ensure that we have everything we need.
# To do so, we ensure we have
#   - a working local/lib directory relative to the started script
#   - a working cpanm installer in local/bin
#   - all modules required by this set of modules installed
#

our $DEBUG = 1;

our $root_dir  = abs_path($FindBin::Bin);
our $local     = "$root_dir/local";
our $local_lib = "$local/lib";
our $perl_lib  = "$local/lib/perl5";
our $local_bin = "$local/bin";
our $cpanm     = "$local/bin/cpanm";
our $local_tmp = "$local/tmp";

sub import {
    say "Provision::Prepare, root_dir=$root_dir" if $DEBUG;

    create_local()  if !-d $local;
    install_cpanm() if !-x $cpanm;
    install_missing_modules();
    # ...
    
    eval "use lib '$local_lib'";
    
    say "Provision::Prepare done" if $DEBUG;
}

sub create_local {
    foreach my $dir ($local, $local_lib, $local_bin, $local_tmp) {
        say "mkdir $dir..." if $DEBUG;

        mkdir $dir
            or die "could not create '$dir': $!";
    }
}

sub install_cpanm {
    my $packages = get_via_http('http://cpan.noris.de/modules/02packages.details.txt');
    $packages =~ m{App::cpanminus\s+([0-9.]+)\s+(M/MI/MIYAGAWA/.*?\.gz)}xms
        or die 'could not find cpanm in package list, stopping';
    my $version = $1;
    my $path = $2;
    say "CPANM: version=$version, path=$path" if $DEBUG;
    
    my $tar_gz = get_via_http("http://cpan.noris.de/authors/id/$path")
        or die 'could not load cpanm .tar.gz';
    
    open my $fh, '>', "$local_tmp/cpanm.tar.gz"
        or die 'could not write .tar.gz';
    print $fh $tar_gz;
    close $fh
        or die 'error writing .tar.gz';
    
    system "tar xfz $local_tmp/cpanm.tar.gz -O --include '*/bin/cpanm' > $cpanm"
        and die 'could not extract .tar.gz';
    
    chmod 0555, $cpanm;
    
    say 'installed cpanm' if $DEBUG;
}

sub install_missing_modules {
    foreach my $module (<DATA>) {
        chomp $module;
        
        install_module($module) if !module_installed($module);
    }
}

sub get_via_http {
    my $url = shift;
    
    my $http = HTTP::Lite->new;
    my $req = $http->request($url)
        or die "Unable to get document: $!";
    return $http->body();
}

1;

__DATA__
namespace::autoclean
Moose
