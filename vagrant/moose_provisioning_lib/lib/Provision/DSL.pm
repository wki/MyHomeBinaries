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
# use Provision::DSL::Prepare;

#
# starting here, we are in good shape and can use everything we need.
#
use Path::Class;
use Module::Pluggable search_path => 'Provision::DSL::Entity', sub_name => 'entities';
use Module::Pluggable search_path => 'Provision::DSL::Source', sub_name => 'sources';
use Module::Load;
use Moose;
use Moose::Util::TypeConstraints qw(class_type coerce
                                    from via
                                    find_type_constraint);

our @EXPORT = qw(Done done OS Os os);

sub import {
    my $package = caller;

    warnings->import();
    strict->import();
    feature->import(':5.10');

    my $app = _instantiate_app_class();
    _create_and_export_entity_keywords($package, $app);
    _create_and_export_source_keywords($package, $app);
    _export_symbols($package);
}

sub _instantiate_app_class {
    my $os = os();
    my $app_class = "Provision::DSL::App::$os";
    load $app_class;

    return $app_class->new_with_options;
}

sub _create_and_export_entity_keywords {
    my ($package, $app) = @_;

    my $os = os();
    my %class_for;
    foreach my $entity_class (__PACKAGE__->entities) {
        my $entity_name = $entity_class;
        $entity_name =~ s{\A Provision::DSL::Entity::(?:_(\w+)\::)?}{}xms;
        next if $1 && $1 ne $os;

        $entity_name =~ s{::}{_}xmsg;

        next if exists $class_for{$entity_name}
             && length $class_for{$entity_name} > length $entity_class;
        $class_for{$entity_name} = $entity_class;
        
        # create class-types and coercions before loading entity modules
        if (!find_type_constraint($entity_name)) {
            class_type $entity_name,
                { class => $entity_class };
            coerce $entity_name,
                from 'Str',
                via { $entity_class->new({app => $app, name => $_}) };
        }
    }
    $app->_entity_class_for(\%class_for);

    while (my ($entity_name, $entity_class) = each %class_for) {
        load $entity_class;

        no strict 'refs';
        no warnings 'redefine';
        *{"${package}::${entity_name}"} = sub {
            my $entity = $app->entity($entity_name, @_);

            if (defined wantarray) {
                return $entity
            } else {
                $entity->execute;
            }
        };
    }
}

sub _create_and_export_source_keywords {
    my ($package, $app) = @_;

    foreach my $source_class (__PACKAGE__->sources) {
        load $source_class;
        
        my $source_name = $source_class;
        $source_name =~ s{\A Provision::DSL::Source::}{}xms;
        
        no strict 'refs';
        no warnings 'redefine'; # occurs during test
        *{"${package}::${source_name}"}   = sub { $source_class->new(@_) };
        *{"${package}::\l${source_name}"} = *{"${package}::${source_name}"};
    }
}

sub _export_symbols {
    my $package = shift;

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

sub Done { goto &done }
sub done {
    say 'Done.';

    exit;
}

no Moose::Util::TypeConstraints;
1;
