package Provision::DSL::Entity::_OSX::Group;
use Moose;
use namespace::autoclean;
extends 'Provision::DSL::Entity::Group';

our $DSCL = '/usr/bin/dscl';

after create => sub {
    my $self = shift;

    $self->log_dryrun("would create Group '${\$self->name}'")
        and return;

    my $group = "/Groups/${\$self->name}";

    $self->system_command($DSCL, '.', -create => $group); 
    $self->system_command($DSCL, '.', -append => $group,
                          PrimaryGroupID => $self->gid);
};

after remove => sub {
    my $self = shift;
    
    my $members = (getgrgid($self->gid))[3];
    die "Cannot remove group ${\$self->name}: in use by '$members'";
    
    $self->log_dryrun("would remove Group '${\$self->name}'")
        and return;
    
    $self->system_command($DSCL, '.', -delete => "/Groups/${\$self->name}");
};

__PACKAGE__->meta->make_immutable;
1;
