package Provision::Entity::User::OSX;
use Moose;
use autodie ':all';
use namespace::autoclean;
extends 'Provision::Entity::User';

our $DSCL = '/usr/bin/dscl';

sub _build_home_directory {
    my $self = shift;
    
    return (getpwuid($self->uid))[7] // "/Users/${\$self->name}"; # / fake editor
}

sub create {
    my $self = shift;

    $self->log_dryrun("would create User '${\$self->name}'")
        and return;

    $self->home_directory->mkpath;
    chown $self->uid, $self->gid, $self->home_directory;
    
    my $user  = "/Users/${\$self->name}";
    my $group = "/Groups/${\$self->name}";

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
}

__PACKAGE__->meta->make_immutable;
1;
