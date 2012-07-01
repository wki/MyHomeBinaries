package Provision::DSL::Source;
use Moose;
use namespace::autoclean;

has name => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has content => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1,
);

# builder must be created in child class

__PACKAGE__->meta->make_immutable;
1;
