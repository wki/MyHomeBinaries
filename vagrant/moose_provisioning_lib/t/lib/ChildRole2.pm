package ChildRole2;
use Moose::Role;

before method => sub { $_[0]->show('before CR2::m') };
after  method => sub { $_[0]->show('after CR2::m') };

no Moose::Role;
1;
