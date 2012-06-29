package Provision::Role::Copy;
use Moose::Role;
use Provision::Types;

has copy => (
    is => 'ro',
    isa => 'File',
    coerce => 1,
    predicate => 'has_copy',
);

no Moose::Role;
1;
