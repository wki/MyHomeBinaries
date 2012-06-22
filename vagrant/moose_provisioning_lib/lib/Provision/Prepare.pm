package Provision::Prepare;
use strict;
use warnings;
use feature ':5.10';
use FindBin;
use Cwd 'abs_path';
use File::Find;
use HTTP::Lite;  ### must be included, but is PP and only 1 File

#
# we must ensure that we have everything we need.
# To do so, we ensure we have
#   - a working local/lib directory relative to the started script
#   - a working cpanm installer in local/bin
#   - all modules required by this set of modules installed
#

our $DEBUG = 1;
our $CPAN_MIRROR = 'http://cpan.noris.de';
our $PACKAGE_URL = "$CPAN_MIRROR/modules/02packages.details.txt.gz";
our $AUTHOR_URL  = "$CPAN_MIRROR/authors/id";

our $root_dir  = abs_path($FindBin::Bin);
our $lib       = "$root_dir/lib";
our $local     = "$root_dir/local";
our $local_lib = "$local/lib";
our $perl_lib  = "$local/lib/perl5";
our $local_bin = "$local/bin";
our $cpanm     = "$local/bin/cpanm";
our $local_tmp = "$local/tmp";

our $packages;
our %distribution_for;

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
    load_package_file();
    
    $packages =~ m{App::cpanminus\s+([0-9.]+)\s+(M/MI/MIYAGAWA/.*?\.gz)}xms
        or die 'could not find cpanm in package list, stopping';
    my $version = $1;
    my $path = $2;
    say "CPANM: version=$version, path=$path" if $DEBUG;
    
    my $tar_gz = get_via_http("$AUTHOR_URL/$path")
        or die 'could not load cpanm .tar.gz';
    
    write_to($tar_gz, '>', "$local_tmp/cpanm.tar.gz");
    
    system "tar xfz $local_tmp/cpanm.tar.gz -O --include '*/bin/cpanm' > $cpanm"
        and die 'could not extract .tar.gz';
    
    chmod 0755, $cpanm;
    
    say 'installed cpanm' if $DEBUG;
}

sub install_missing_modules {
    load_package_file();
    
    say 'collecting  modules...' if $DEBUG;
    
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
    }, $lib);
    
    say for sort keys %install_module;
}

sub load_package_file {
    return if $packages;
    
    my $package_file = "$local_tmp/packages.gz";
    
    if (!-f $package_file || -M $package_file > 1) {
        my $packages_gz = get_via_http($PACKAGE_URL);
        write_to($packages_gz, '>', "$local_tmp/packages.gz");
    }
    
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
