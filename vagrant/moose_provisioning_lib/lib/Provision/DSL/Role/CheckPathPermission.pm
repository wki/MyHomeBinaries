package Provision::DSL::Role::CheckPathPermission;
use Moose::Role;

requires 'path', 'permission', 'is_current', 'create', 'change';

around is_current => sub {
    my ($orig, $self) = @_;
    
    return ($self->stat->mode & 255) == $self->permission && $self->$orig();
};

after ['create', 'change'] => sub {
    my $self = shift;
    
    chmod $self->permission, $self->path;
};

no Moose::Role;
1;
