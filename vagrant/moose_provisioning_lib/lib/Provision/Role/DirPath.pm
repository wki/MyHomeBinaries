package Provision::Role::DirPath;
use Moose::Role;
use Provision::Types;

has path => (
    is => 'ro',
    isa => 'Dir',
    required => 1,
    coerce => 1,
    lazy_build => 1,
);

sub _build_path { $_[0]->name }

no Moose::Role;
1;
