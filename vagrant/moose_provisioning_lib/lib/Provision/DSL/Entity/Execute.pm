package Provision::DSL::Entity::Execute;
use Moose;
use Provision::DSL::Types;

extends 'Provision::DSL::Entity';

has path => (
    is => 'ro',
    isa => 'ExecutableFile',
    coerce => 1,
    required => 1,
    lazy_build => 1,
);

sub _build_path { $_[0]->name }

has arguments => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [] },
);

after create => sub { 
    my $self = shift;
    
    $self->->system_command($self->path, @{$self->arguments}),
};

__PACKAGE__->meta->make_immutable;
1;
