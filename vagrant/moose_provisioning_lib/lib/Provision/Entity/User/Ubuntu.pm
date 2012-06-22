package Provision::Entity::User::Ubuntu;
use Moose;
use namespace::autoclean;
extends 'Provision::Entity::User';

sub create {
    my $self = shift;
    
    ...
}

__PACKAGE__->meta->make_immutable;
1;
