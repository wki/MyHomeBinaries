package Provision::Entity::Tree;
use Moose;
# use MooseX::Types::Path::Class 'Dir';
# use Path::Class;
use Provision::Types;
use List::MoreUtils qw(all none);
use namespace::autoclean;

extends 'Provision::Entity';
with 'Provision::Role::User',
     'Provision::Role::Group',
     'Provision::Role::Permission',
     'Provision::Role::FilePath',
     'Provision::Role::PathOperation';

sub _build_permission { '755' }

has provide => (
    is => 'ro',
    isa => 'DirList',
    default => sub { [] },
);

has remove => (
    is => 'ro',
    isa => 'DirList',
    default => sub { [] },
);

sub is_present {
    my $self = shift;
    
    return -d $self->path
        && $self->path_has_requested_permission
        && $self->path_has_requested_owner
        && (none { -d $_->{path} } @{$self->remove})
        && (all { $self->path_has_requested_permission($_->{path}, $_->{permission})} 
            @{$self->provide})
        && (all { $self->path_has_requested_owner($_->{path}, $_->{user}, $_->{group})} 
            @{$self->provide});
}

sub create {
    my $self = shift;
    
    # remove all existing 'remove' entries
    
    # create and fix all 'provide' entries
}

__PACKAGE__->meta->make_immutable;
1;
