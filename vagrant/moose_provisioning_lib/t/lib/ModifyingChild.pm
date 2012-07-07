package ModifyingChild;
use Moose;
use namespace::autoclean;

extends 'Parent';
with 'ChildRole1', 'ChildRole2';

before method => sub { $_[0]->show('before MC::m') };
after  method => sub { $_[0]->show('after MC::m') };

# method() is not implemented in child.
# this activates all method calls in parent and all roles

__PACKAGE__->meta->make_immutable;
1;
