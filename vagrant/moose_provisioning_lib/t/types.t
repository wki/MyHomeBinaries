use Test::More;
use Test::Exception;

{
    package C;
    use Moose;
    use Provision::DSL::Types;
    
    has p => (is => 'rw', isa => 'Permission');
}

my $c = C->new;

# permission
{
    dies_ok { $c->p({}) } 'setting a hashref as a permission dies';
    dies_ok { $c->p([]) } 'setting an arrayref as a permission dies';
    
    dies_ok { $c->p('foo') } 'setting a non-octal string as a permission dies';
    dies_ok { $c->p('07') } 'setting a short octal string as a permission dies';
    
    lives_ok { $c->p('007') } 'setting an octal string lives';
    
    foreach my $perm (qw(000 001 004 007 010 040 070 111 777)) {
        lives_ok { $c->p($perm) } "setting permission to '$perm' lives";
        is oct($c->p), oct($perm), "permission '$perm' is ${\oct($perm)}";
    }
}


done_testing;
