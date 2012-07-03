use Test::More;
use Provision::DSL::App;

use ok 'Provision::DSL::Entity';

{
    package E1;
    use Moose;
    extends 'Provision::DSL::Entity';

    has _diagnostics => (
        is => 'rw',
        isa => 'ArrayRef',
        default => sub { [] },
    );

    sub is_ok0  { $_[0]->is_ok(0) }
    sub is_ok1  { $_[0]->is_ok(1) }

    sub process0 { $_[0]->process(0) }
    sub process1 { $_[0]->process(1) }

    sub create { push @{$_[0]->_diagnostics}, 'create' }
    sub change { push @{$_[0]->_diagnostics}, 'change' }
    sub remove { push @{$_[0]->_diagnostics}, 'remove' }
}

my @testcases = (
    {
        name => 'no attributes',
        attributes => {},
        expect => {is_present => 1, is_current => 1, state => 'current' },
    },
    {
        name => 'only_if (1)',
        attributes => {only_if => sub{1}},
        expect => {is_present => 0, is_current => 1, state => 'missing' },
    },
    {
        name => 'only_if (0)',
        attributes => {only_if => sub{0}},
        expect => {is_present => 1, is_current => 1, state => 'current' },
    },
    {
        name => 'not_if (1)',
        attributes => {not_if => sub{1}},
        expect => {is_present => 1, is_current => 1, state => 'current' },
    },
    {
        name => 'not_if (0)',
        attributes => {not_if => sub{0}},
        expect => {is_present => 0, is_current => 1, state => 'missing' },
    },
    {
        name => 'update_if (1)',
        attributes => {update_if => sub{1}},
        expect => {is_present => 1, is_current => 0, state => 'outdated' },
    },
    {
        name => 'update_if (0)',
        attributes => {update_if => sub{0}},
        expect => {is_present => 1, is_current => 1, state => 'current' },
    },
    {
        name => 'keep_if (1)',
        attributes => {keep_if => sub{1}},
        expect => {is_present => 1, is_current => 1, state => 'current' },
    },
    {
        name => 'keep_if (0)',
        attributes => {keep_if => sub{0}},
        expect => {is_present => 1, is_current => 0, state => 'outdated' },
    },

    {
        name => 'is_ok missing',
        attributes => {state => 'missing'},
        expect => {is_ok0 => 1, is_ok1 => 0},
    },
    {
        name => 'is_ok outdated',
        attributes => {state => 'outdated'},
        expect => {is_ok0 => 0, is_ok1 => 0},
    },
    {
        name => 'is_ok current',
        attributes => {state => 'current'},
        expect => {is_ok0 => 0, is_ok1 => 1},
    },

    {
        name => 'process_1 current',
        attributes => {state => 'current'},
        execute => 'process1',
        expect => {_diagnostics => []},
    },
    {
        name => 'process_0 current',
        attributes => {state => 'current'},
        execute => 'process0',
        expect => {_diagnostics => ['remove']},
    },
    {
        name => 'process_1 outdated',
        attributes => {state => 'outdated'},
        execute => 'process1',
        expect => {_diagnostics => ['change']},
    },
    {
        name => 'process_0 outdated',
        attributes => {state => 'outdated'},
        execute => 'process0',
        expect => {_diagnostics => ['remove']},
    },
    {
        name => 'process_1 missing',
        attributes => {state => 'missing'},
        execute => 'process1',
        expect => {_diagnostics => ['create']},
    },
    {
        name => 'process_0 missing',
        attributes => {state => 'missing'},
        execute => 'process0',
        expect => {_diagnostics => []},
    },
);

my $app = Provision::DSL::App->new();

foreach my $testcase (@testcases) {
    my $e = E1->new(
        app => $app,
        name =>$testcase->{name},
        %{$testcase->{attributes}},
    );

    if (exists $testcase->{execute}) {
        my $method = $testcase->{execute};
        $e->$method();
    }

    foreach my $key (sort keys(%{$testcase->{expect}})) {
        if ($testcase->{expect}->{$key} =~ m{\A [01] \z}xms) {
            if ($testcase->{expect}->{$key}) {
                ok $e->$key(),
                   "$testcase->{name}: $key is TRUE";
            } else {
                ok !$e->$key(),
                   "$testcase->{name}: $key is FALSE";
            }
        } elsif (ref $testcase->{expect}->{$key}) {
            is_deeply $e->$key(), $testcase->{expect}->{$key},
                      "$testcase->{name}: $key is as expected";
        } else {
            is $e->$key(), $testcase->{expect}->{$key},
               "$testcase->{name}: $key is $testcase->{expect}->{$key}";
        }
    }
}

done_testing;
