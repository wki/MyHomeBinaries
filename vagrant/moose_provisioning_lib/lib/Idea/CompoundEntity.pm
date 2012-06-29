package CompoundEntity;
use Moose;
use namespace::autoclean;

extends 'EntityBase';

has children => (traits => ['Array'], is => 'rw', isa => 'ArrayRef[EntityBase]', required => 1, handles => { all_children => 'elements' });

sub create {
    my $self = shift;
    
    $_->process(1) for $self->all_children;
}

sub change { goto &create }

sub remove {
    my $self = shift;
    
    $_->process(0) for reverse $self->all_children;
}

__PACKAGE__->meta->make_immutable;
1;
