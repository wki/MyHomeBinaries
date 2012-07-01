package Provision::Role::Group;
use Moose::Role;
use Provision::Types;

has group => (
    is => 'ro',
    isa => 'GroupEntity',
    required => 1,
    coerce => 1,
    lazy_build => 1,
);

sub _build_group {
    my $self = shift;

    if ($self->can('user')) {
        return $self->user->group;
    }
    die 'cannot guess group from user';
}

no Moose::Role;
1;
