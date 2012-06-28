package EntityBase;
use Moose;
use namespace::autoclean;

has name   => (is => 'ro', isa => 'Str',        requried => 1);
has parent => (is => 'ro', isa => 'EntityBase', predicate => 'has_parent');
has state  => (is => 'rw', isa => 'Str',        required => 1, 
                           lazy_build => 1,     clearer => 'clear_state');

# in child classes, do:
# sub _build_state { ... }

sub is_ok {
    my ($self, $wanted) = @_;
    
    return (!$wanted && $self->state eq 'missing')
        || ( $wanted && $self->state eq 'current');
}

sub process {
    my ($self, $wanted) = @_;
    
    return if $self->is_ok($wanted);
    
    ### TODO: handle callbacks
    if (!$wanted) {
        $self->remove();
    } elsif ($self->state eq 'missing') {
        $self->create();
    } else {
        $self->change();
    }
    
    $self->clear_state;
}

# to overload:
sub create {}
sub change {}
sub remove {}

__PACKAGE__->meta->make_immutable;
1;
