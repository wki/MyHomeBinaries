package Provision;
use strict;
use warnings;
use Module::Pluggable require => 1, search_path => 'Provision::Entity';
use Provision::App;

sub import {
    # must have strict, warning in caller
    my $package = caller;
    
    warnings->import();
    strict->import();
    
    # no strict 'refs';
    # *{"${package}::User"} = sub { warn 'user will get set' };
    
    my $app = Provision::App->new_with_options;
    
    foreach my $plugin_class (__PACKAGE__->plugins) {
        my $name = $plugin_class;
        $name =~ s{\A .* ::}{}xms;
        # warn "Plugin: $name";
        
        no strict 'refs';
        *{"${package}::${name}"} = sub {
            $plugin_class->new(app => $app, name => @_)->execute;
        };
    }
}


1;
