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
use Moose;
use Moose::Util::TypeConstraints qw(class_type coerce
                                    from via
                                    find_type_constraint);

our @EXPORT = qw(Done done Os os Resource resource);

sub import {
    my $package = caller;

    warnings->import();
    strict->import();

    my $os = os();
    my $app_class = "Provision::DSL::App::$os";
    load $app_class;
    my $app = $app_class->new_with_options;

    ### FIXME: new order of execution:
    ###   1) collect class_for
    ###      Entity::Xxx will result in Xxx keyword
    ###      Entity::Xxx:::Yyy will result in Xxx keyword
    ###      Entity::_<OS> -- same structure as Entity if wanted
    ###   2) create a 'class_type' for every Entity-Class
    ###   3) export a method for every Entity-Class
    ###   4) save class_for in app->_entity_class_for

    my %class_for;
    # my %class_loaded;
    foreach my $plugin_class (__PACKAGE__->plugins) {

        ### CHECK: can we load classes?
        load $plugin_class;

        ### WRONG: fix to match 1) above!
        my $plugin_name = $plugin_class;
        $plugin_name =~ s{\A Provision::DSL::Entity:: ([^:]+?) (?: :: (\w+))? \z}{$1}xms;
        next if $2 && $2 ne $os;
        next if exists $class_for{$plugin_name}
             && length $class_for{$plugin_name} > length $plugin_class;

        $class_for{$plugin_name} = $plugin_class;

        if (!find_type_constraint($plugin_name)) {
            class_type $plugin_name,
                { class => $plugin_class };
            coerce $plugin_name,
                from 'Str',
                via { $plugin_class->new({app => $app, name => $_}) };
        }

        no strict 'refs';
        no warnings 'redefine';
        *{"${package}::${plugin_name}"} = sub {
            my $plugin_object = $app->entity($plugin_name, @_);

            if (defined wantarray) {
                return $plugin_object
            } else {
                $plugin_object->execute;
            }
        };
    }

    $app->_entity_class_for(\%class_for);

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

no Moose::Util::TypeConstraints;
1;
