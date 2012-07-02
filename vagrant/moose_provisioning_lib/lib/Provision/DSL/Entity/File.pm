package Provision::DSL::Entity::File;
use Moose;
use Provision::DSL::Types;

extends 'Provision::DSL::Entity';
sub path; sub permission; sub content; # must forward-declare
with 'Provision::DSL::Role::CheckFileExistence',
     'Provision::DSL::Role::CheckFileContent',
     'Provision::DSL::Role::CheckPathPermission';
# TODO: add user/group
     
has path => (is => 'ro', isa => 'PathClassFile', coerce => 1, lazy_build => 1);
sub _build_path { $_[0]->name }

has content => (is => 'ro', isa => 'SourceContent', coerce => 1, required => 1);

has permission => (is => 'ro', isa => 'Permission', required => 1, default => '0644');


__PACKAGE__->meta->make_immutable;
1;
