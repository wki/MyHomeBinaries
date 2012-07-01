package Provision::DSL;
use strict;
use warnings;
use feature ':5.10';
use FindBin;

#
# up to this point, nothing bad happens.
# Provision::Prepare will ensure that everything requested to continue
# is there or dies otherwise.
#
use Provision::DSL::Prepare;

#
# starting here, we are in good shape and can use everything we need.
#
use Path::Class;
use Module::Pluggable search_path => 'Provision::DSL::Entity';
use Module::Load;

our @EXPORT = qw(Done done Os os Resource resource);

sub import {
    my $package = caller;
    
    warnings->import();
    strict->import();
    
    my $os = os();
    my $app_class = "Provision::DSL::App::$os";
    eval "use $app_class";
    my $app = $app_class->new_with_options;
    
    ### FIXME: new order of execution:
    ###   1) collect class_for
    ###   2) create a 'class_type' for every Entity-Class
    ###   3) export a method for every Entity-Class
    ###   4) save class_for in app->_entity_class_for
    
    my %class_for;
    my %class_loaded;
    foreach my $plugin_class (__PACKAGE__->plugins) {
        my $name = $plugin_class;
        $name =~ s{\A Provision::DSL::Entity:: ([^:]+?) (?: :: (\w+))? \z}{$1}xms;
        next if $2 && $2 ne $os;
        next if exists $class_for{$name} 
             && length $class_for{$name} > length $plugin_class;
        
        $class_for{$name} = $plugin_class;
        
        no strict 'refs';
        no warnings 'redefine';
        *{"${package}::${name}"} = sub {
            $class_loaded{$plugin_class}++
                or load $plugin_class;
            
            my %args;
            $args{name} = shift @_ if !ref $_[0];
            %args = (%args, ref $_[0] eq 'HASH' ? %$_[0] : @_);
            $plugin_class->new(%args)->execute;
        };
    }
    
    $app->_entity_class_for( \%class_for );
    
    foreach my $symbol (@EXPORT) {
        no strict 'refs';
        *{"${package}::${symbol}"} = *{"Provision::DSL::$symbol"};
    }
}

sub OS { goto &os }
sub Os { goto &os }
sub os {
    if ($^O eq 'darwin') {
        return 'OSX';
    } else {
        return 'Ubuntu'; ### FIXME: maybe wrong!
    }
}

sub Resource { goto &resource }
sub resource {
    my $path = shift;
    
    my $resource_dir = dir("$FindBin::Bin/resources");
    die 'resource dir not found' if !-d $resource_dir;
    
    my $dir = $resource_dir->subdir($path);
    return -d $dir
        ? $dir
        : $resource_dir->file($path);
}

sub Done { goto &done }
sub done {
    say 'Done.';
    
    exit;
}

1;
