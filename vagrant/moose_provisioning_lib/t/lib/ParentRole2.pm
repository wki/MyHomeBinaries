package ParentRole2;
use Moose::Role;

before method => sub { $_[0]->show('before PR2::m') };
after  method => sub { $_[0]->show('after PR2::m') };

no Moose::Role;
1;
