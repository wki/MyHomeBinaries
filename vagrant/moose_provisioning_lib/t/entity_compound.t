use Test::More;
use Provision::DSL::App;

use ok 'Provision::DSL::Entity::Compound';

{
    package E;
    use Moose;
    extends 'Provision::DSL::Entity';
    
    has [qw(is_present is_current)] => (
        is => 'ro',
        isa => 'Bool',
        default => 1,
    );
    
    sub create { push @{$_[0]->parent->_diagnostics}, "${\$_[0]->name}:create" }
    sub change { push @{$_[0]->parent->_diagnostics}, "${\$_[0]->name}:change" }
    sub remove { push @{$_[0]->parent->_diagnostics}, "${\$_[0]->name}:remove" }
}

{
    package C;
    use Moose;
    extends 'Provision::DSL::Entity::Compound';
    
    has _diagnostics => (
        is => 'rw',
        isa => 'ArrayRef',
        default => sub { [] },
    );
    
    before create => sub { push @{$_[0]->_diagnostics}, 'create' };
    before change => sub { push @{$_[0]->_diagnostics}, 'change' };
    after  remove => sub { push @{$_[0]->_diagnostics}, 'remove' };
}

my @testcases = (
    # no children
    {
        name => 'empty',
        child_states => [],
        process_arg => 1,
        expect => {state => 'current', is_present => 1, is_current => 1},
        diagnostics => [],
    },
    
    # 1 child
    {
        name => 'missing->1',
        child_states => [ {is_present => 0, is_current => 1} ],
        process_arg => 1,
        expect => {state => 'missing', is_present => 0, is_current => 1},
        diagnostics => ['create', 'child_1:create'],
    },
    {
        name => 'missing->0',
        child_states => [ {is_present => 0, is_current => 1} ],
        process_arg => 0,
        expect => {state => 'missing', is_present => 0, is_current => 1},
        diagnostics => [],
    },
    {
        name => 'outdated->1',
        child_states => [ {is_present => 1, is_current => 0} ],
        process_arg => 1,
        expect => {state => 'outdated', is_present => 1, is_current => 0},
        diagnostics => ['change', 'child_1:change'],
    },
    {
        name => 'outdated->0',
        child_states => [ {is_present => 1, is_current => 0} ],
        process_arg => 0,
        expect => {state => 'outdated', is_present => 1, is_current => 0},
        diagnostics => ['child_1:remove', 'remove'],
    },
    {
        name => 'current->1',
        child_states => [ {is_present => 1, is_current => 1} ],
        process_arg => 1,
        expect => {state => 'current', is_present => 1, is_current => 1},
        diagnostics => [],
    },
    {
        name => 'current->0',
        child_states => [ {is_present => 1, is_current => 1} ],
        process_arg => 0,
        expect => {state => 'current', is_present => 1, is_current => 1},
        diagnostics => ['child_1:remove', 'remove'],
    },
    
    # 2 children
    {
        name => 'missing,outdated->1',
        child_states => [ {is_present => 0, is_current => 1}, {is_present => 1, is_current => 0} ],
        process_arg => 1,
        expect => {state => 'outdated', is_present => 1, is_current => 0},
        diagnostics => ['change', 'child_1:create', 'child_2:change'],
    },
    {
        name => 'missing,outdated->0',
        child_states => [ {is_present => 0, is_current => 1}, {is_present => 1, is_current => 0} ],
        process_arg => 0,
        expect => {state => 'outdated', is_present => 1, is_current => 0},
        diagnostics => ['child_2:remove', 'remove'],
    },
);

foreach my $testcase (@testcases) {
    my $app = Provision::DSL::App->new();
    
    my $c = C->new({app => $app, name => $testcase->{name}});
    $i = 1;
    for my $state (@{$testcase->{child_states}}) {
        $c->add_child(E->new({app => $app, name => "child_${\$i++}", parent => $c, %$state}));
    }
    
    foreach my $key (sort keys(%{$testcase->{expect}})) {
        if ($testcase->{expect}->{$key} =~ m{\A [01] \z}xms) {
            if ($testcase->{expect}->{$key}) {
                ok $c->$key(),
                   "$testcase->{name}: $key is TRUE";
            } else {
                ok !$c->$key(),
                   "$testcase->{name}: $key is FALSE";
            }
        } elsif (ref $testcase->{expect}->{$key}) {
            is_deeply $c->$key(), $testcase->{expect}->{$key},
                      "$testcase->{name}: $key is as expected";
        } else {
            is $c->$key(), $testcase->{expect}->{$key},
               "$testcase->{name}: $key is $testcase->{expect}->{$key}";
        }
    }
    
    $c->process($testcase->{process_arg});
    
    is_deeply $c->_diagnostics, $testcase->{diagnostics},
              "$testcase->{name}: diagnostics OK";
}


done_testing;
