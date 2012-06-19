package Provision;
use strict;
use warnings;
use feature ':5.10';
use Module::Pluggable require => 1, search_path => 'Provision::Entity';
use Provision::App;

our @EXPORT = qw(done);

sub import {
    my $package = caller;
    
    warnings->import();
    strict->import();
    
    my $app = Provision::App->new_with_options;
    
    foreach my $plugin_class (__PACKAGE__->plugins) {
        my $name = $plugin_class;
        $name =~ s{\A .* ::}{}xms;
        
        no strict 'refs';
        *{"${package}::${name}"} = sub {
            $plugin_class->new(app => $app, name => @_)->execute;
        };
    }
    
    foreach my $export (@EXPORT) {
        no strict 'refs';
        *{"${package}::${export}"} = *{"Provision::$export"};
    }
}

sub done {
    say 'Done.';
    
    exit;
}

1;
