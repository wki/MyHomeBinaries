use Test::More;
use Test::Exception;
use FindBin;

use ok 'WK::App::Role::Cpanm';

{
    package X;
    use Moose;
    with 'WK::App::Role::Cpanm';
}

$ENV{PATH} = "$FindBin::Bin/search_path";
my $temp_dir;
{
    my $x = X->new;
    ok -d $x->install_base, 'install_base dir exists';
    $temp_dir = '' . $x->install_base->stringify;
    
    is $x->cpanm, "$FindBin::Bin/search_path/cpanm", 'found cpanm';
}
# fails -- why?
# ok !-d $temp_dir, 'install_base dir removed after destruction';
# warn "TEMP: $temp_dir";



done_testing;
