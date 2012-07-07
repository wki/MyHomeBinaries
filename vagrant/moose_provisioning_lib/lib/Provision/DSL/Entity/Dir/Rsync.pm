package Provision::DSL::Entity::Dir::Rsync;
use Moose;
use namespace::autoclean;

extends 'Provision::DSL::Entity';

has path => (
    is => 'ro',
    isa => 'PathClassDir',
    coerce => 1,
    required => 1,
);

has content => (
    is => 'ro',
    isa => 'ExistingDir',
    coerce => 1,
    required => 1,
);

has exclude => (
    is => 'ro',
    isa => 'DirList',
    coerce => 1,
    required => 1,
);

# is_current ::: rsync -n -v, output > 1 zeile ==> not current

# after create/change ::: rsync

__PACKAGE__->meta->make_immutable;
1;
