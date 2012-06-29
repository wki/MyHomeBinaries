package EntityBase;
use Moose;
use namespace::autoclean;

has name   => (is => 'ro', isa => 'Str',        requried => 1);
has parent => (is => 'ro', isa => 'EntityBase', predicate => 'has_parent');
has state  => (is => 'rw', isa => 'Str',        required => 1, 
                           lazy_build => 1,     clearer => 'clear_state');

# # if these checks are present, they are taken for check,
# # is_present() or is_current() otherwise
# has _check_if_present => (is => 'rw', isa => 'CodeRef', predicate => '_has_present_check');
# has _check_if_current => (is => 'rw', isa => 'CodeRef', predicate => '_has_current_check');

# precedence over class-methods is_present, is_current
# present: only_if, not_if, current: update_if, keep_if
has only_if   => (is => 'rw', isa => 'CodeRef', predicate => 'has_only_if');
has not_if    => (is => 'rw', isa => 'CodeRef', predicate => 'has_not_if');
has update_if => (is => 'rw', isa => 'CodeRef', predicate => 'has_update_if');
has keep_if   => (is => 'rw', isa => 'CodeRef', predicate => 'has_keep_if');


# in child classes, do:
# sub _build_state { ... }

sub _build_state {
    my $self = shift;
    
    return 'missing'  if !$self->is_present;
    return 'outdated' if !$sels->is_current;
    return 'current';
}


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

# maybe augment in child class
sub is_present { 
    my $self = shift;
    
    return $self->has_only_if ? !$self->only_if->()
         : $self->has_not_if  ? $self->not_if->()
         : inner();
}

# maybe augment in child class
sub is_current {
    my $self = shift;
    
    return $self->has_update_if ? !$self->update_if->()
         : $self->has_keep_if   ? $self->keep_if->()
         : inner();
}

# must be overloaded
sub create {}
sub change {}
sub remove {}

__PACKAGE__->meta->make_immutable;
1;
