package Provision::Entity::Package;
use Moose;
use namespace::autoclean;
extends 'Provision::Entity';

has installed_version => (
    is => 'rw',
    isa => 'Str',
    predicate => 'is_present',
);

has latest_version => (
    is => 'rw',
    isa => 'Str',
    lazy_build => 1,
);

sub is_current {
    my $self = shift;
    
    return 0 if !$self->is_present;
    
    return $self->latest_version eq $self->installed_version;
}

__PACKAGE__->meta->make_immutable;
1;
