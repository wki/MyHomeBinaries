package Provision::DSL::Role::PathOwner;
use Moose::Role;
use Provision::DSL::Types;

requires 'path', 'is_current', 'create', 'change';

has user => (
    is => 'ro', 
    isa => 'User',
    lazy_build => 1,
    coerce => 1,
);

has group => (
    is => 'ro', 
    isa => 'Group',
    lazy_build => 1,
    coerce => 1,
);

around is_current => sub {
    my ($orig, $self) = @_;
    
    return -e $self->path 
        && ($self->path->stat->uid == $self->user->uid)
        && ($self->path->stat->gid == $self->group->gid)
        && $self->$orig();
};

after ['create', 'change'] => sub {
    my $self = shift;
    
    $self->log_dryrun("would chown ${\$self->user}:${\$self->group}, ${\$self->path}")
        and return;
    
    chown $self->user->uid, $self->group->gid, $self->path;
};

no Moose::Role;
1;
