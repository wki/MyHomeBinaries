package Provision::Types;
# use Moose;
use MooseX::Types -declare => [ 'UserEntity' ];
use MooseX::Types::Moose 'Str';

class_type UserEntity,
    { class => 'Provision::Entity::User' };
coerce UserEntity,
    from Str,
    via { Provision::Entity::User->new( { name => $_ } ) };



1;

