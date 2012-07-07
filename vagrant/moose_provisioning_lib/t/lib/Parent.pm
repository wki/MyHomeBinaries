package Parent;
use Moose;
use namespace::autoclean;

with 'ParentRole1', 'ParentRole2';

has message => (
    traits => ['Array'],
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    handles => {
        show => 'push',
    },
);

before method => sub { $_[0]->show('before P::m') };
after  method => sub { $_[0]->show('after P::m') };

sub method { $_[0]->show('in P::m') }

__PACKAGE__->meta->make_immutable;
1;
