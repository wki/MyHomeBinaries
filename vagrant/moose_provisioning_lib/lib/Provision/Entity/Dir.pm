package Provision::Entity::Dir;
use Moose;
use Provision::Types;
use namespace::autoclean;

extends 'Provision::Entity';
with 'Provision::Role::User',
     'Provision::Role::Group',
     'Provision::Role::Permission',
     'Provision::Role::FilePath',
     'Provision::Role::PathOperation';

sub _build_permission { '755' }

sub is_present {
    my $self = shift;
    
    return -d $self->path
           && $self->path_has_requested_permission
           && $self->path_has_requested_owner;
}

sub create {
    my $self = shift;
    
    $self->path->remove if -f $self->path;

    $self->path->mkpath if !-d $self->path;

    $self->set_path_permission;
    $self->set_path_owner;
}

__PACKAGE__->meta->make_immutable;
1;
