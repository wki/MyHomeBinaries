package Provision::DSL::Entity::_OSX::User;
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

    $self->app->system_command($DSCL, '.', -create => $group); 
    $self->app->system_command($DSCL, '.', -append => $group,
                               PrimaryGroupID => $self->group->gid);

    $self->app->system_command($DSCL, '.', -create => $user);
    $self->app->system_command($DSCL, '.', -append => $user,
                               PrimaryGroupID => $self->group->gid);
    $self->app->system_command($DSCL, '.', -append => $user,
                               UniqueID => $self->uid);
    $self->app->system_command($DSCL, '.', -append => $user,
                               NFSHomeDirectory => $self->home_directory);
    $self->app->system_command($DSCL, '.', -append => $user,
                               UserShell => '/bin/bash');
};

after remove => sub {
    my $self = shift;
    
    $self->log_dryrun("would remove User '${\$self->name}'")
        and return;
    
    $self->app->system_command($DSCL, '.', -delete => "/Users/${\$self->name}");
};

__PACKAGE__->meta->make_immutable;
1;
