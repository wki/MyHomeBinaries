package Provision::DSL::Role::CheckPathPermission;
use Moose::Role;

requires 'path', 'permission', 'is_current', 'create', 'change';

around is_current => sub {
    my ($orig, $self) = @_;
    
    return ($self->path->stat->mode & 255) == oct($self->permission) && $self->$orig();
};

after ['create', 'change'] => sub {
    my $self = shift;
    
    $self->log_dryrun("would chmod ${\oct($self->permission)}, ${\$self->path}")
        and return;
    
    chmod oct($self->permission), $self->path;
};

no Moose::Role;
1;
