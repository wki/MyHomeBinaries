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

# builder must be created in child class if content wanted

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;
    
    my %args = ();
    $args{name} = shift if !ref $_[0];
    %args = (%args, ref $_[0] eq 'HASH' ? %{$_[0]} : @_);
    
    return $class->$orig(%args);
};

__PACKAGE__->meta->make_immutable;
1;
