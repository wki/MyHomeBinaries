package Provision::Entity::Service::OSX;
use Moose;
use Provision::Types;
use namespace::autoclean;
extends 'Provision::Entity::Service';

has plist => (
    is => 'ro',
    isa => 'File',
    required => 1,
    lazy_build => 1,
    coerce => 1,
);

sub _build_plist {
}

has label => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    lazy_build => 1,
);

sub _build_label {
}

sub is_present {
    # check running === is_running
}

sub create {
    # running ? stop : start
}

sub _is_running {
    my $self = shift;
    
    # launchctl list | grep $self->name
}

sub _find_plist_file {
    my $self = shift;
    
    # search in /Library/LaunchDaemons
    #           /Library/LaunchAgents
    #           ~user/Library/LaunchAgents

}

sub _do_reload {
    my $self = shift;
}

__PACKAGE__->meta->make_immutable;
1;
