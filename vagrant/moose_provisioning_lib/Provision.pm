package Provision;
use strict;
use warnings;
use feature ':5.10';
use Module::Pluggable require => 1, search_path => 'Provision::Entity';
# use Provision::App;

our @EXPORT = qw(done os);

sub import {
    my $package = caller;
    
    warnings->import();
    strict->import();
    
    my $os = os();
    my $app_class = "Provision::App::$os";
    eval "use $app_class";
    my $app = $app_class->new_with_options;
    
    my %class_for;
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
            $plugin_class->new(app => $app, name => @_)->execute;
        };
    }
    
    foreach my $export (@EXPORT) {
        no strict 'refs';
        *{"${package}::${export}"} = *{"Provision::$export"};
    }
}

sub os {
    return 'OSX'; ### FIXME: wrong!
    return 'Ubuntu'; ### FIXME: wrong!
}

sub done {
    say 'Done.';
    
    exit;
}

1;
