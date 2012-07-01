package Provision::DSL::Entity::Execute;
use Moose;
use Provision::DSL::Types;

extends 'Provision::DSL::Entity';
with 'Provision::Role::ExecuteCommand';

sub _build_path { $_[0]->name }

sub create {
    my $self = shift;

    $self->execute_command;
}

__PACKAGE__->meta->make_immutable;
1;
