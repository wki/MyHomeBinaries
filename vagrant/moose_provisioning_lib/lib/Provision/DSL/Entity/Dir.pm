package Provision::DSL::Entity::Dir;
use Moose;
use Provision::DSL::Types;

extends 'Provision::DSL::Entity';
with 'Provision::DSL::Role::CheckDirExistence',
     'Provision::DSL::Role::ChecKPathPermission';
# TODO: add user/group

has path => (is => 'ro', isa => 'PathClassDir', coerce => 1, lazy_build => 1);
sub _build_path { $_[0]->name }

has permission => (is => 'ro', isa => 'Permission', coerce => 1, required => 1, default => '0755');

__PACKAGE__->meta->make_immutable;
1;
