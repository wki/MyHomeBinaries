package Provision::Entity::Nginx;
use Moose;
use namespace::autoclean;
extends 'Provision::Entity';

# has package 'nginx';

# has service 'nginx';



sub service {
    my $self = shift;
    my $state = shift;
    
    # ensure service is in $state
    
    return $self;
}

sub site {
    my $self = shift;
    
    # ensure site is as required
    
    return $self;
}

sub reload {
    my $self = shift;
    
    return sub { $self->_service->reload };
}

__PACKAGE__->meta->make_immutable;
1;
