package Provision::DSL::Entity::File;
use Moose;
use Provision::DSL::Types;

extends 'Provision::DSL::Entity';
sub path; sub content; # must forward-declare
with 'Provision::DSL::Role::CheckFileExistence',
     'Provision::DSL::Role::CheckFileContent',
     'Provision::DSL::Role::PathPermission',
     'Provision::DSL::Role::PathOwner';

sub _build_permission { '0644' }
     
has path => (
    is => 'ro', 
    isa => 'PathClassFile', 
    lazy_build => 1,
    coerce => 1, 
);
sub _build_path { $_[0]->name }

has content => (
    is => 'ro', 
    isa => 'SourceContent', 
    coerce => 1, 
    required => 1,
);

__PACKAGE__->meta->make_immutable;
1;
