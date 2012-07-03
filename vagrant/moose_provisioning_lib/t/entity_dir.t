use Test::More;
use Test::Exception;
use Path::Class;
use FindBin;

my $t_dir = dir($FindBin::Bin)->absolute->resolve;
my $x_dir = $t_dir->subdir('x');
system "/bin/rm -rf '$x_dir'";
$x_dir->mkpath;

use ok 'Provision::DSL';

can_ok 'main', 'Dir';

my $d;


undef $d;
dies_ok { $d = Dir() }
        'creating an unnamed dir entity dies';


undef $d;
lives_ok { $d = Dir("$FindBin::Bin/x/y") }
         'creating a named but unknown dir entity lives';
isa_ok $d, 'Provision::DSL::Entity::Dir';
ok !-d $d->path, 'an unknown dir does not exist';
ok !$d->is_present, 'an unknown dir is not present';

lives_ok { $d->process(1) } 'creating a former unknown dir lives';
ok -d $d->path, 'a former unknown dir exists';
ok $d->is_present, 'a former unknown dir is present';

lives_ok { $d->process(0) } 'removing a dir lives';
ok !-d $d->path, 'a removed dir does not exist';
ok !$d->is_present, 'a removed dir is not present';


undef $d;
lives_ok { $d = Dir("$FindBin::Bin/x") }
         'creating a named and known dir entity lives';
isa_ok $d, 'Provision::DSL::Entity::Dir';
ok -d $d->path, 'a known dir exists';
ok $d->is_present, 'a known dir is present';


done_testing;
