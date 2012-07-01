package Provision::Entity::Service::Ubuntu;
use Moose;
use namespace::autoclean;
extends 'Provision::Entity::Service';

sub _do_reload {
    my $self = shift;
}

__PACKAGE__->meta->make_immutable;
1;
