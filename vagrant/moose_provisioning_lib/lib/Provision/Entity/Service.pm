package Provision::Entity::Service;
use Moose;
use namespace::autoclean;

extends 'Provision::Entity';
with 'Provision::Role::Copy',
     'Provision::Role::FilePath';

has running => (
    is => 'ro',
    isa => 'Bool',
    required => 1,
    default => 1,
);

sub _build_user { 'root' }
sub _build_group { 'wheel' }

# returns a subref that actually does the reload
sub reload {
    my $self = shift;
    
    return sub { $self->_do_reload(@_) };
}

# must get overloaded
sub _do_reload { die 'service-reload not implemented' }

__PACKAGE__->meta->make_immutable;
1;
