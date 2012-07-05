use Test::More;
use Test::Exception;
use FindBin;

use ok 'Provision::DSL::Source::Resource';

my $root_dir = "$FindBin::Bin/../resources";


# existing dir
{
    foreach my $dir (qw(dir1 /dir1 dir1/ /dir1/)) {
        my $r;
        $r = Provision::DSL::Source::Resource->new(
            {root_dir => $root_dir, name => $dir}
        );
        isa_ok $r->path, 'Path::Class::Dir';
        ok -d $r->path, "Dir '$dir' exists";
        is $r->path->basename, 'dir1', "Dir '$dir' is dir1";
        dies_ok { $r->content }
                "retrieving dir content from '$dir' dies";
    }
}

# not existing file
{
    foreach my $file (qw(no_such_file.txt /no_such_file.txt no_such_file.txt/ /no_such_file.txt/
                         dir1/no_such_file.txt /dir1/no_such_file.txt
                         dir1/dir2/no_such_file.txt /dir1/dir2/no_such_file.txt)) {
        my $r = Provision::DSL::Source::Resource->new(
                    {root_dir => $root_dir, name => $file}
                );
        dies_ok { my $dummy = $r->path }
            "accessing path from not existing '$file' dies";
    }
}

# existing file
{
    foreach my $file (qw(dir1/file1.txt /dir1/file1.txt dir1/file1.txt/ /dir1/file1.txt/)) {
        my $r;
        $r = Provision::DSL::Source::Resource->new(
            {root_dir => $root_dir, name => $file}
        );
        isa_ok $r->path, 'Path::Class::File';
        ok -f $r->path, "File '$file' exists";
        is $r->path->basename, 'file1.txt', "File '$file' is file1.txt";
        is $r->content, "FILE:file1\nline2", "File '$file' content OK";
    }
}

done_testing;
