package Provision::DSL::Entity::Service;
use Moose;
use namespace::autoclean;

extends 'Provision::DSL::Entity::File';

__PACKAGE__->meta->make_immutable;
1;
