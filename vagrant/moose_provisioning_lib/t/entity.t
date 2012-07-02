use Test::More;
use Provision::DSL::App;

use ok 'Provision::DSL::Entity';

{
    package E1;
    use Moose;
    extends 'Provision::DSL::Entity';

    # has [qw(+only_if +not_if +update_if +keep_if)] => (
    #     is => 'rw';
    # );
    
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
    # TODO: more testcases

);

my $app = Provision::DSL::App->new();

foreach my $testcase (@testcases) {
    my $e = E1->new(
        app => $app,
        name =>$testcase->{name},
        %{$testcase->{attributes}},
    );

    foreach my $key (sort keys(%{$testcase->{expect}})) {
        if ($testcase->{expect}->{$key} =~ m{\A [01] \z}xms) {
            if ($testcase->{expect}->{$key}) {
                ok $e->$key(),
                   "$testcase->{name}: $key is TRUE";
            } else {
                ok !$e->$key(),
                   "$testcase->{name}: $key is FALSE";
            }
        } else {
            is $e->$key(), $testcase->{expect}->{$key},
               "$testcase->{name}: $key is $testcase->{expect}->{$key}";
        }
    }
}

done_testing;
