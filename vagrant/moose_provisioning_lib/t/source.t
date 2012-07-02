use Test::More;
use Test::Exception;

use ok 'Provision::DSL::Source';

{
    package S;
    use Moose;
    extends 'Provision::DSL::Source';
    
    has a1 => (
        is => 'ro',
        isa => 'Str',
        predicate => 'has_a1',
    );
}

dies_ok { S->new() }
        'creating a Source w/o name dies';

# strange: this works!
# dies_ok { S->new({name => 'foo', unknown => 42}) }
#         'creating a Source w/ unknown attribute dies';

my $s;
lives_ok { $s = S->new('name1') }
        'creating a Source w/ string arg lives';
is $s->name, 'name1', 'name is name1';
ok !$s->has_a1, 'name1: a1 not set';

undef $s;
lives_ok { $s = S->new(name2 => {a1 => 'foo'}) }
        'creating a Source w/ string and hashref arg lives';
is $s->name, 'name2', 'name is name2';
is $s->a1, 'foo', 'a1 is foo';

undef $s;
lives_ok { $s = S->new({name => 'name3', a1 => 'bar'}) }
        'creating a Source w/ hashref arg lives';
is $s->name, 'name3', 'name is name3';
is $s->a1, 'bar', 'a1 is bar';

done_testing;
