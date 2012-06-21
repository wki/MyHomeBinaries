package Provision::Entity::Package;
use Moose;
use namespace::autoclean;
extends 'Provision::Entity';

has installed_version => (
    is => 'rw',
    isa => 'Str',
    predicate => 'is_present',
);

sub create {
    my $self = shift;
    
    # install package x
}

__PACKAGE__->meta->make_immutable;
1;
