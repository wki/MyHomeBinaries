use Test::More;
use Test::Exception;
use Path::Class;
use FindBin;

my $t_dir = dir($FindBin::Bin)->absolute->resolve;
my $x_dir = $t_dir->subdir('x');
system "/bin/rm -rf '$x_dir'";
$x_dir->mkpath;

use ok 'Provision::DSL';

can_ok 'main', 'File';

my $f;


undef $f;
dies_ok { $f = File() }
        'creating an unnamed dir entity dies';


undef $f;
lives_ok { $f = File("$FindBin::Bin/x/file.ext", {content => 'foo'}) }
         'creating a named but unknown file entity lives';
isa_ok $f, 'Provision::DSL::Entity::File';
ok !-f $f->path, 'an unknown file does not exist';
ok !$f->is_present, 'an unknown file is not present';

lives_ok { $f->process(1) } 'creating a former unknown file lives';
ok -f $f->path, 'a former unknown file exists';
ok $f->is_present, 'a former unknown file is present';
is scalar $f->path->slurp, 'foo', 'conent is "foo"';

lives_ok { $f->process(0) } 'removing a file lives';
ok !-f $f->path, 'a removed file does not exist';
ok !$f->is_present, 'a removed file is not present';


### TODO: create a file from a resource, change it and update again

# undef $f;
# lives_ok { $f = File("$FindBin::Bin/x") }
#          'creating a named and known file entity lives';
# isa_ok $f, 'Provision::DSL::Entity::file';
# ok -d $f->path, 'a known file exists';
# ok $f->is_present, 'a known file is present';


done_testing;
