package Provision::App;
use Moose;
use namespace::autoclean;
with 'MooseX::Getopt';

has verbose => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Bool',
    default => 0,
    cmd_aliases => 'v',
);

has debug => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Bool',
    default => 0,
);

has dryrun => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Bool',
    default => 0,
    cmd_aliases => 'n',
);

__PACKAGE__->meta->make_immutable;
1;
