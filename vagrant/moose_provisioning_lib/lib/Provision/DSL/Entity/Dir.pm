package Provision::DSL::Entity::Dir;
use Moose;
use Provision::DSL::Types;

extends 'Provision::DSL::Entity';
sub path; # must forward-declare
with 'Provision::DSL::Role::CheckDirExistence',
     'Provision::DSL::Role::PathPermission',
     'Provision::DSL::Role::PathOwner';

sub _build_permission { '0755' }

has path => (
    is => 'ro', 
    isa => 'PathClassDir', 
    coerce => 1, 
    lazy_build => 1,
);
sub _build_path { $_[0]->name }

__PACKAGE__->meta->make_immutable;
1;
