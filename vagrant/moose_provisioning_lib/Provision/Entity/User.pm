package Provision::Entity::User;
use Moose;
use namespace::autoclean;
extends 'Provision::Entity';

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
