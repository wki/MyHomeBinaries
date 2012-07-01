package Provision::Role::FilePath;
use Moose::Role;
use Provision::Types;

has path => (
    is => 'rw',  # eg Service::OSX must be able to change
    isa => 'File',
    required => 1,
    coerce => 1,
    lazy_build => 1,
);

sub _build_path { $_[0]->name }

no Moose::Role;
1;
