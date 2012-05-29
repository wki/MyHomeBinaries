use Test::More;
use Test::Exception;
use FindBin;
use Path::Class;

use ok 'WK::Types::PathClass';

{
    package X;
    use Moose;
    use WK::Types::PathClass qw(ExistingFile ExecutableFile ExistingDir DistributionDir);

    has existing_file    => ( is => 'rw', isa => ExistingFile,    coerce => 1 );
    has executable_file  => ( is => 'rw', isa => ExecutableFile,  coerce => 1 );
    has existing_dir     => ( is => 'rw', isa => ExistingDir,     coerce => 1 );
    has distribution_dir => ( is => 'rw', isa => DistributionDir, coerce => 1 );
}

my $t_dir = Path::Class::Dir->new($FindBin::Bin)->resolve->absolute;

$x = X->new;

# Existing File
{
    dies_ok { $x->existing_file('/path/to/nothing') }
            'setting non-existing file dies';

    dies_ok { $x->existing_file($FindBin::Bin) }
            'setting a dir as a file dies';

    lives_ok { $x->existing_file("$FindBin::Bin/search_path/not_executable.txt") }
             'setting a file lives';

    is $x->existing_file("$FindBin::Bin/../t/./search_path/not_executable.txt")->stringify,
       $t_dir->subdir('search_path')->file('not_executable.txt')->stringify,
       'existing file path is resolved';

    isa_ok $x->existing_file, 'Path::Class::File';
}

# Executable File
{
    dies_ok { $x->executable_file('/path/to/nothing') }
            'setting non-existing file dies';

    dies_ok { $x->executable_file($FindBin::Bin) }
            'setting a dir as a file dies';

    dies_ok { $x->executable_file("$FindBin::Bin/search_path/not_executable.txt") }
            'setting a non-executable file dies';

    lives_ok { $x->executable_file("$FindBin::Bin/search_path/cpanm") }
             'setting an executable file lives';

    is $x->executable_file("$FindBin::Bin/../t/search_path/cpanm")->stringify,
       $t_dir->subdir('search_path')->file('cpanm')->stringify,
       'executable file path is resolved';

    isa_ok $x->executable_file, 'Path::Class::File';
}

# Existing Dir
{
    dies_ok { $x->existing_dir('/path/to/nothing') }
            'setting non-existing dir dies';

    dies_ok { $x->existing_dir("$FindBin::Bin/search_path/cpanm") }
            'setting a file as a dir dies';

    lives_ok { $x->existing_dir($FindBin::Bin) }
             'setting a dir lives';

    is $x->existing_dir("$FindBin::Bin/../t/./search_path")->stringify,
       $t_dir->subdir('search_path')->stringify,
       'existing dir path is resolved';

    isa_ok $x->existing_dir, 'Path::Class::Dir';
}

# Distribution Dir
{
    dies_ok { $x->distribution_dir('/path/to/nothing') }
            'setting non-existing dir dies';

    dies_ok { $x->distribution_dir("$FindBin::Bin/search_path/cpanm") }
            'setting a file as a dir dies';

    dies_ok { $x->distribution_dir($FindBin::Bin) }
            'setting a non-distribution dir dies';

    lives_ok { $x->distribution_dir("$FindBin::Bin/sample_dist") }
             'setting a distribution dir lives';

    is $x->distribution_dir("$FindBin::Bin/../t/./sample_dist")->stringify,
       $t_dir->subdir('sample_dist')->stringify,
       'distribution dir path is resolved';

    isa_ok $x->distribution_dir, 'Path::Class::Dir';
}

done_testing;
