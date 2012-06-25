package Provision;
use strict;
use warnings;
use feature ':5.10';
use FindBin;

#
# up to this point, nothing bad happens.
# Provision::Prepare will ensure that everything requested to continue
# is there or dies otherwise.
#
use Provision::Prepare;

#
# starting here, we are in good shape and can use everything we need.
#
use Path::Class;
use Module::Pluggable search_path => 'Provision::Entity';

our @EXPORT = qw(done os resource);

sub import {
    my $package = caller;
    
    warnings->import();
    strict->import();
    
    my $os = os();
    my $app_class = "Provision::App::$os";
    eval "use $app_class";
    my $app = $app_class->new_with_options;
    
    my %class_for;
    my %required;
    foreach my $plugin_class (__PACKAGE__->plugins) {
        my $name = $plugin_class;
        $name =~ s{\A Provision::Entity:: ([^:]+?) (?: :: (\w+))? \z}{$1}xms;
        next if $2 && $2 ne $os;
        next if exists $class_for{$name} 
             && length $class_for{$name} > length $plugin_class;
        
        $class_for{$name} = $plugin_class;
        
        no strict 'refs';
        no warnings 'redefine';
        *{"${package}::${name}"} = sub {
            $required{$plugin_class}++ or eval "use $plugin_class";
            $plugin_class->new(app => $app, name => @_)->execute;
        };
    }
    
    $app->_resource_class_for( \%class_for );
    
    foreach my $export (@EXPORT) {
        no strict 'refs';
        *{"${package}::${export}"} = *{"Provision::$export"};
    }
}

sub os {
    if ($^O eq 'darwin') {
        return 'OSX';
    } else {
        return 'Ubuntu'; ### FIXME: maybe wrong!
    }
}

sub resource {
    my $path = shift;
    
    my $resource_dir = dir("$FindBin::Bin/resources");
    die 'resource dir not found' if !-d $resource_dir;
    
    my $dir = $resource_dir->subdir($path);
    return -d $dir
        ? $dir
        : $resource_dir->file($path);
}

sub done {
    say 'Done.';
    
    exit;
}

1;
