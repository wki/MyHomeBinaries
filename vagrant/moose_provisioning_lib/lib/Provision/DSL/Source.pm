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

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;
    
    ### FIXME: same logic as App::entity()
    if (@_ == 1 && !ref $_[0]) {
        return $class->$orig(name => $_[0]);
    } else {
        return $class->$orig(@_);
    }
};

__PACKAGE__->meta->make_immutable;
1;
