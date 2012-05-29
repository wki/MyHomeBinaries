use Test::More;
use Test::Exception;
use FindBin;

use ok 'WK::App::Role::LocateBinary';

{
    package X;
    use Moose;
    with 'WK::App::Role::LocateBinary';
}


my $x = X->new;
isa_ok $x, 'X';
can_ok $x, 'locate_binary';


$ENV{PATH} = '/nonsense:/not/existing';
dies_ok { $x->locate_binary('cpanm') }
        'searching in non-existing path dies';


$ENV{PATH} = "$FindBin::Bin:$FindBin::Bin/search_path";
is $x->locate_binary('cpanm'),
   "$FindBin::Bin/search_path/cpanm",
   'binary found in given search path';


done_testing;
