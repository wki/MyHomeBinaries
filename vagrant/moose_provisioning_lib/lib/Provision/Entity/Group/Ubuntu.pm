package Provision::Entity::Group::Ubuntu;
use Moose;
use namespace::autoclean;
extends 'Provision::Entity::Group';

sub create {
    my $self = shift;
    
    ...
}

__PACKAGE__->meta->make_immutable;
1;
