package Provision::Entity::File;
use Moose;
use namespace::autoclean;
use Provision::Types;

extends 'Provision::Entity';
with 'Provision::Role::User';
with 'Provision::Role::Group';
with 'Provision::Role::Permission';

sub _build_permission { '755' }

has provide => (
    is => 'rw',
    isa => 'DirList',
    default => sub { [] },
);

has remove => (
    is => 'rw',
    isa => 'DirList',
    default => sub { [] },
);

sub is_present {
    my $self = shift;
    
    return if grep { -d $_->{path} } @{$self->remove};
    return if grep { !$_->_path_is_ok($_) } @{$self->create};
    
    return 1;
}

sub _path_is_ok {
    my ($self, $path) = @_;
    
    return if !-d $path->{path};
    return if !$self->_path_has_requested_permission($path->{path});
    return if !$self->_path_has_requested_owner($path->{path});
    
}

sub _path_has_requested_permission {
    
}

sub _path_has_requested_owner {
    
}

sub create {
    my $self = shift;
    
    
}

__PACKAGE__->meta->make_immutable;
1;
