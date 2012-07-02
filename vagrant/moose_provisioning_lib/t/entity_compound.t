use Test::More;
use Provision::DSL::App;

use ok 'Provision::DSL::Entity::Compound';

{
    package E;
    use Moose;
    extends 'Provision::DSL::Entity';
    
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
    
    sub create { push @{$_[0]->_diagnostics}, 'create' }
    sub change { push @{$_[0]->_diagnostics}, 'change' }
    sub remove { push @{$_[0]->_diagnostics}, 'remove' }
}

my @testcases = (
    {
        name => 'empty',
        child_states => [],
        process_arg => 1,
        expect => {state => 'current', is_present => 1, is_current => 1},
        diagnostics => [],
    },
    
    ### TODO: add more test cases.
);

foreach my $testcase (@testcases) {
    my $app = Provision::DSL::App->new();
    
    my $c = C->new({app => $app, name => $testcase->{name}});
    $i = 1;
    for my $state (@{$testcase->{child_states}}) {
        warn "STATE: $state";
        $c->add_child(E->new({app => $app, name => "child_${\$i++}", parent => $c, state => $state}));
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
