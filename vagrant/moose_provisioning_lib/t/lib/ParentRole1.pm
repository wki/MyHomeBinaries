package ParentRole1;
use Moose::Role;

before method => sub { $_[0]->show('before PR1::m') };
after  method => sub { $_[0]->show('after PR1::m') };

no Moose::Role;
1;
