package Provision::Role::PathOperation;
use Moose::Role;
use Provision; # has User and Group functions. ??? bad ???

sub path_has_requested_permission {
    my $self = shift;
    my $path = shift // $self->path;
    
    return ($self->permission & 255) == ((stat $path)[2] & 255);
}

sub set_path_permission {
    my $self = shift;
    my $path = shift // $self->path;
    my $permission = shift // $self->permission;
    
    chmod $permission, $path;
}

sub path_has_requested_owner {
    my $self = shift;
    my $path = shift // $self->path;
    my $uid = $_[0] ? User(shift)->uid  : $self->user->uid;
    my $gid = $_[0] ? Group(shift)->gid : $self->group->gid;
    
    return ($uid == (stat $path)[4])
        && ($gid == (stat $path)[5]);
}

sub set_path_owner {
    my $self = shift;
    my $path = shift // $self->path;
    
    chown $self->user->uid, $self->group->gid, $path;
}

no Moose::Role;
1;
