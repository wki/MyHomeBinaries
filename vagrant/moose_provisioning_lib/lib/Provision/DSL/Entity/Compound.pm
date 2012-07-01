package Provision::DSL::Entity::Compound;
use Moose;
use namespace::autoclean;

extends 'Provision::DSL::Entity';

has children => (
    traits => ['Array'], 
    is => 'rw', 
    isa => 'ArrayRef[Entity]', 
    required => 1,
    default => sub { [] },
    handles => {
        all_children => 'elements',
        add_child    => 'push',
    },
);

sub create {
    my $self = shift;
    
    $_->process(1) for $self->all_children;
}

sub remove {
    my $self = shift;
    
    $_->process(0) for reverse $self->all_children;
}

__PACKAGE__->meta->make_immutable;
1;
