package Provision::DSL::Entity::File;
use Moose;
use Provision::DSL::Types;

extends 'Provision::DSL::Entity';
with 'Provision::DSL::Role::CheckFileExistence',
     'Provision::DSL::Role::CheckFileContent',
     'Provision::DSL::Role::ChecKPathPermission';
     
has path => (is => 'ro', isa => 'PathClassFile', coerce => 1, lazy_build => 1);
sub _build_path { $_[0]->name }

has content => (is => 'ro', isa => 'SourceContent', coerce => 1, required => 1);

has permission => (is => 'ro', isa => 'Permission', coerce => 1, required => 1, default => '0644');


__PACKAGE__->meta->make_immutable;
1;
