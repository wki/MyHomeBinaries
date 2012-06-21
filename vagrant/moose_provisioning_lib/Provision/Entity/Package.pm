package Provision::Entity::Package;
use Moose;
use namespace::autoclean;
extends 'Provision::Entity';

sub is_present {
    my $self = shift;
    
    # check if we have package x installed
}

sub create {
    my $self = shift;
    
    # install package x
}

__PACKAGE__->meta->make_immutable;
1;
