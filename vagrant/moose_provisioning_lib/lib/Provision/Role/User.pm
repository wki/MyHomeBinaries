package Provision::Role::User;
use Moose::Role;
use Provision::Types;

has user => (
    is => 'ro',
    isa => 'UserEntity',
    required => 1,
    coerce => 1,
    lazy_build => 1,
);

# allow overloading in role-consuming class
sub _build_user {
    die 'no builder for user present.';
}

no Moose::Role;
1;
