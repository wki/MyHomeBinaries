package Provision::DSL::Entity::Compound;
use Moose;
use Provision::DSL::Types;
use List::MoreUtils qw(any all none);
use namespace::autoclean;

extends 'Provision::DSL::Entity';

has children => (
    traits => ['Array'], 
    is => 'rw', 
    isa => 'ArrayRef[Entity]', 
    required => 1,
    lazy_build => 1,
    handles => {
        all_children    => 'elements',
        add_child       => 'push',
        has_no_children => 'is_empty',
    },
);

sub _build_children { [] }

override is_present => sub {
    my $self = shift;
    
    return super() && ($self->has_no_children 
                       || any { $_->is_present } $self->all_children);
};

override is_current => sub {
    my $self = shift;
    
    return super() && all { $_->is_current } $self->all_children;
};

sub create { $_->process(1) for $_[0]->all_children }
sub change { $_->process(1) for $_[0]->all_children }
sub remove { $_->process(0) for reverse $_[0]->all_children }

__PACKAGE__->meta->make_immutable;
1;
