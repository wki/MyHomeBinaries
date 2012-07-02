package Provision::DSL::Entity;
use Moose;
use namespace::autoclean;

has name => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has app => (
    is => 'ro',
    isa => 'Provision::DSL::App',
    required => 1,
    handles => [qw(verbose dryrun
                   log log_dryrun log_debug
                   entity)],
);

has parent => (
    is => 'ro',
    isa => 'Provision::DSL::Entity::Base',
    predicate => 'has_parent',
);

has state  => (
    is => 'rw',
    isa => 'Str',
    required => 1,
    lazy_build => 1,
    clearer => 'clear_state',
);

# precedence over methods is_present, is_current
# present: only_if, not_if, current: update_if, keep_if
has only_if   => (is => 'ro', isa => 'CodeRef', predicate => 'has_only_if');
has not_if    => (is => 'ro', isa => 'CodeRef', predicate => 'has_not_if');
has update_if => (is => 'ro', isa => 'CodeRef', predicate => 'has_update_if');
has keep_if   => (is => 'ro', isa => 'CodeRef', predicate => 'has_keep_if');


sub _build_state {
    my $self = shift;

    return 'missing'  if !$self->is_present;
    return 'outdated' if !$self->is_current;
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

    ### TODO: handle callbacks ???
    if (!$wanted) {
        $self->remove();
    } elsif ($self->state eq 'missing') {
        $self->create();
    } else {
        $self->change();
    }

    $self->clear_state;
}

sub is_present {
    my $self = shift;

    return $self->has_only_if ? !$self->only_if->()
         : $self->has_not_if  ? $self->not_if->()
         : 1;
}

sub is_current {
    my $self = shift;

    return $self->has_update_if ? !$self->update_if->()
         : $self->has_keep_if   ? $self->keep_if->()
         : 1;
}

# must be overloaded
sub create {}
sub change { goto &create }
sub remove {}

__PACKAGE__->meta->make_immutable;
1;
