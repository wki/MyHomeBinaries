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

# erroneous parameters
undef $d;
dies_ok { $d = Dir() }
        'creating an unnamed dir entity dies';


# creating and removing a directory
undef $d;
lives_ok { $d = Dir("$FindBin::Bin/x/y") }
         'creating a named but unknown dir entity lives';
isa_ok $d, 'Provision::DSL::Entity::Dir';
ok !-d $d->path, 'an unknown dir does not exist';
ok !$d->is_present, 'an unknown dir is not present';

lives_ok { $d->process(1) } 'creating a former unknown dir lives';
ok -d $d->path, 'a former unknown dir exists';
ok $d->is_present, 'a former unknown dir is present';
ok $d->is_current, 'a former unknown dir is current';

lives_ok { $d->process(0) } 'removing a dir lives';
ok !-d $d->path, 'a removed dir does not exist';
ok !$d->is_present, 'a removed dir is not present';


# checking of an existing directory
undef $d;
lives_ok { $d = Dir("$FindBin::Bin/x") }
         'creating a named and known dir entity lives';
isa_ok $d, 'Provision::DSL::Entity::Dir';
ok -d $d->path, 'a known dir exists';
ok $d->is_present, 'a known dir is present';
ok $d->is_current, 'a known dir is current';


# multiple dirs and copying from a resource
system "/bin/rm -rf '$x_dir'";
$x_dir->mkpath;
undef $d;
$d = Dir("$FindBin::Bin/x/foo",{
        mkdir => [qw(abc def ghi/jkl)],
        content => Resource('dir1'),
    });
ok !$d->is_present, 'dir with structure is not present';
ok !$d->is_current, 'dir with structure is not current';

$d->process(1);

ok $d->is_present, 'dir with structure is present after process';
ok $d->is_current, 'dir with structure is current after process';

foreach my $dir (qw(abc def ghi ghi/jkl dir2)) {
    ok -d $d->path->subdir($dir), "subdir '$dir' present";
}

done_testing;
