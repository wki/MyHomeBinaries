package Provision::DSL::Role::PathPermission;
use Moose::Role;
use Provision::DSL::Types;

requires 'path', 'is_current', 'create', 'change';

has permission => (
    is => 'ro', 
    isa => 'Permission', 
    required => 1, 
    lazy_build => 1,
);

around is_current => sub {
    my ($orig, $self) = @_;
    
    return ($self->path->stat->mode & 511) == (oct($self->permission) & 511) 
        && $self->$orig();
};

after ['create', 'change'] => sub {
    my $self = shift;
    
    $self->log_dryrun("would chmod ${\oct($self->permission)}, ${\$self->path}")
        and return;
    
    chmod oct($self->permission), $self->path;
};

no Moose::Role;
1;
