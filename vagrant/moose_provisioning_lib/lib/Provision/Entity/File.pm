package Provision::Entity::File;
use Moose;
use namespace::autoclean;
use Provision::Types;

extends 'Provision::Entity';
with 'Provision::Role::User',
     'Provision::Role::Group',
     'Provision::Role::Permission',
     'Provision::Role::FilePath',
     'Provision::Role::PathOperation';

sub _build_permission { '644' }

has content => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    default => '',
);

sub is_present {
    my $self = shift;
    
    return -f $self->path
           && $self->path_has_requested_permission
           && $self->path_has_requested_owner
           && scalar($self->path->slurp) eq $self->content;
}

sub create {
    my $self = shift;
    
    ### FIXME: what happens if a dir with same name exists?
    if (-d $self->path) {
        die "should delete dir: '$self->path' before file creation";
    }
    
    my $fh = $self->path->openw;
    print $fh $self->content;
    close $fh;
    
    $self->set_path_permission;
    $self->set_path_owner;
}

__PACKAGE__->meta->make_immutable;
1;
