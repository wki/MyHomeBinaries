package Provision::DSL::Entity::Group::OSX;
use Moose;
use namespace::autoclean;
extends 'Provision::DSL::Entity::Group';

our $DSCL = '/usr/bin/dscl';

after create => sub {
    my $self = shift;

    $self->log_dryrun("would create Group '${\$self->name}'")
        and return;

    my $group = "/Groups/${\$self->name}";

    $self->system_command($DSCL, '.', -create => $group); 
    $self->system_command($DSCL, '.', -append => $group,
                          PrimaryGroupID => $self->gid);
};

__PACKAGE__->meta->make_immutable;
1;
