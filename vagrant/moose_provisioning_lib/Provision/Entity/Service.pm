package Provision::Entity::Service;
use Moose;
use namespace::autoclean;
extends 'Provision::Entity';

# returns a subref that actually does the reload
sub reload {
    my $self = shift;
    
    return sub { $self->_do_reload(@_) };
}

# do the reload
sub _do_reload {
    my $self = shift;
}

__PACKAGE__->meta->make_immutable;
1;
