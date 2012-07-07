use Test::More;
use Test::Exception;
use Path::Class;
use FindBin;

my $t_dir = dir($FindBin::Bin)->absolute->resolve;
my $x_dir = $t_dir->subdir('x');
system "/bin/rm -rf '$x_dir'";
$x_dir->mkpath;

use ok 'Provision::DSL';

can_ok 'main', 'Rsync';

$r = Rsync "$FindBin::Bin/x" => {
    content => "$FindBin::Bin/resources/dir1",
    exclude => 'dir3',
};

# syncing into a fresh directory
ok !$r->is_current, 'not current before sync into an empty dir';
$r->execute;
ok $r->is_current, 'current after sync into an empty dir';

my @files = qw(file1.txt file2.txt dir2/file3.txt);
ok -f $x_dir->file($_), "$_ is present"
    for @files;


# a changed file is discovered and updated
my $fh = $x_dir->file($files[0])->openw;
print $fh 'updated file1';
close $fh;

ok !$r->is_current, 'not current before sync into an empty dir';
$r->execute;
ok $r->is_current, 'current after sync into an empty dir';

is scalar $x_dir->file($files[0])->slurp,
   "FILE:file1\nline2",
   'file 1 updated';


# a superfluous file and dir is discovered and deleted, exclude honored
$x_dir->subdir('dir3')->mkpath;
$x_dir->subdir('dir4')->mkpath;
my $fh = $x_dir->file('file_xx.txt')->openw;
print $fh 'superfluous file1';
close $fh;

ok !$r->is_current, 'not current before sync into an empty dir';
$r->execute;
ok $r->is_current, 'current after sync into an empty dir';

ok !-f $x_dir->file('file_xx.txt'),
   'superfluous file deleted';
ok -d $x_dir->subdir('dir3'),
    'excluded dir is kept';
ok !-d $x_dir->subdir('dir4'),
    'not-excluded dir is deleted';

done_testing;
