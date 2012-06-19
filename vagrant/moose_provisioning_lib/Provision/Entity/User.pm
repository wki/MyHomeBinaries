package Provision::Entity::User;
use Moose;
use MooseX::Types::Path::Class 'Dir';
use namespace::autoclean;
extends 'Provision::Entity';

has uid => (
    is => 'rw',
    isa => 'Int',
);

has gid => (
    is => 'rw',
    isa => 'Int',
);

has home_directory => (
    is => 'rw',
    isa => Dir,
);

sub is_present {
    my $self = shift;
    
    return getpwnam($self->name);
}

sub create {
    my $self = shift;
    
    $self->log_dryrun("would create User '${\$self->name}'")
        and return;
    
    $self->log("create user '${\$self->name}'");
}

__PACKAGE__->meta->make_immutable;
1;
