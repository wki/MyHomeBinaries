package Provision::DSL::Entity::User::OSX;
use Moose;
use namespace::autoclean;

extends 'Provision::DSL::Entity::User';

our $DSCL = '/usr/bin/dscl';

sub _build_home_directory {
    my $self = shift;
    
    return (getpwuid($self->uid))[7] // "/Users/${\$self->name}"; # /
}

after create => sub {
    my $self = shift;

    $self->log_dryrun("would create User '${\$self->name}'")
        and return;

    my $user  = "/Users/${\$self->name}";
    my $group = "/Groups/${\$self->group->name}";

    $self->system_command($DSCL, '.', -create => $group); 
    $self->system_command($DSCL, '.', -append => $group,
                          PrimaryGroupID => $self->gid);

    $self->system_command($DSCL, '.', -create => $user);
    $self->system_command($DSCL, '.', -append => $user,
                          PrimaryGroupID => $self->gid);
    $self->system_command($DSCL, '.', -append => $user,
                          UniqueID => $self->uid);
    $self->system_command($DSCL, '.', -append => $user,
                          NFSHomeDirectory => $self->home_directory);
    $self->system_command($DSCL, '.', -append => $user,
                          UserShell => '/bin/bash');
};

__PACKAGE__->meta->make_immutable;
1;
