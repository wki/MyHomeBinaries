package ChildRole1;
use Moose::Role;

before method => sub { $_[0]->show('before CR1::m') };
after  method => sub { $_[0]->show('after CR1::m') };

no Moose::Role;
1;
