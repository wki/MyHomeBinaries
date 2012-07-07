use Test::More;
use FindBin;
use lib "$FindBin::Bin/lib";
use ok 'Parent';
use ok 'Child';
use ok 'ModifyingChild';

#
# without inheritance,
# method, class-modifiers and role-mofifiers are called
#
my $p = Parent->new;
$p->method();

is join(" / ", @{$p->message}),
   'before P::m / before PR2::m / before PR1::m / '
 . 'in P::m / '
 . 'after PR1::m / after PR2::m / after P::m',
   'parent calling order is OK';


#
# with inheritance and overwriting method
# ONLY CHILD METHOD AND MODIFIERS ARE CALLED, PARENT IS IGNORED
#
my $c = Child->new;
$c->method();

is join(" / ", @{$c->message}),
   'before C::m / before CR2::m / before CR1::m / ' # parent missing
 . 'in C::m / '
 . 'after CR1::m / after CR2::m / after C::m',      # parent missing
   'child calling order is OK';


#
# only using modifiers behaves AS EXPECTED
#
my $m = ModifyingChild->new;
$m->method();

is join(" / ", @{$m->message}),
   'before MC::m / before CR2::m / before CR1::m / '
 . 'before P::m / before PR2::m / before PR1::m / '
 . 'in P::m / '
 . 'after PR1::m / after PR2::m / after P::m / '
 . 'after CR1::m / after CR2::m / after MC::m',
   'modifying child calling order is OK';


done_testing;
