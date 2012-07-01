package Provision::DSL::Entity::_Ubuntu::User;
use Moose;
use namespace::autoclean;

extends 'Provision::DSL::Entity::User';

our $DSCL = '/usr/bin/dscl';

sub _build_home_directory {
    my $self = shift;
    
    return (getpwuid($self->uid))[7] // "/home/${\$self->name}"; # /
}

after create => sub {
    my $self = shift;

    $self->log_dryrun("would create User '${\$self->name}'")
        and return;

    ...
};


__PACKAGE__->meta->make_immutable;
1;
