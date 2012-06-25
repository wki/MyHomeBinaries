package Provision::Role::Permission;
use Moose::Role;
use Provision::Types;

has permission => (
    is => 'ro',
    isa => 'Permission',
    required => 1,
    lazy_build => 1,
);

no Moose::Role;
1;
