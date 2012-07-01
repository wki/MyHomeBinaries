package Provision::DSL::CheckIf;
use Moose;
use namespace::autoclean;

# in DSL:
#   sub Executes = sub {
#       my @args = @_;
#       sub { Provision::DSL::CheckIf::Executes->new(@_)->is_ok(@args) }
#   }
#

has entity => (
    is => 'ro',
    isa => 'Provision::DSL::Entity',
    required => 1,
);

sub is_ok {
    die '"is_ok()" must be overloaded!';
}

__PACKAGE__->meta->make_immutable;
1;
