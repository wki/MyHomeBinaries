package WK::App::Easy;
use Modern::Perl;
use autodie ':all';
use Moose;
use Module::Pluggable
    search_path => ['WK::App::Easy::Command'],
    sub_name => 'get_command_classes';
use MooseX::Types::Path::Class 'Dir';
use List::Util 'first';
use Path::Class;
# use Try::Tiny;
use WK::App::Easy::FileSearch;

extends 'WK::App';
with 'MooseX::Getopt';

#
# very bad but necessary hack.
# Intercept &GetOptions calls and append an 'Argument callback' option
# ('<>' => sub) at the end of the options list enabling to stop parsing
# the command line as soon as the first unknown argument is seen.
# This is needed to avoid failing on '-' options after a command word
# or an unknown option.
#
around new_with_options => sub {
    my ($orig, $class, @args) = @_;

    use Getopt::Long::Descriptive ();

    my $command;

    no warnings 'redefine';
    my $get_options = \&Getopt::Long::Descriptive::GetOptions;
    local *Getopt::Long::Descriptive::GetOptions = sub {
        return $get_options->(@_, '<>', sub { $command = "$_[0]"; die '!FINISH' });
    };

    my $self = $orig->($class, @args);
    unshift @{$self->extra_argv}, $command if $command;
    return $self;
};

has use_search_path => (
    traits        => ['Getopt'],
    is            => 'rw',
    isa           => 'Bool',
    default       => 0,
    documentation => 'also use system search path $PATH',
);

has app_directory => (
    traits        => ['Getopt'],
    is            => 'rw',
    isa           => Dir,
    coerce        => 1,
    lazy_build    => 1,
    cmd_aliases   => 'd',
    documentation => 'root directory of the application',
);

has lib_directory => (
    traits        => ['Getopt'],
    is            => 'rw',
    isa           => Dir,
    coerce        => 1,
    lazy_build    => 1,
    cmd_aliases   => 'l',
    documentation => 'directory where additional libs reside [local|perl5lib]',
);

has config_suffix => (
    traits        => ['Getopt'],
    is            => 'rw',
    isa           => 'Str',
    predicate     => 'has_config_suffix',
    cmd_aliases   => 'c',
    documentation => 'additional catalyst local config suffix',
);

has plack_env => (
    traits        => ['Getopt'],
    is            => 'rw',
    isa           => 'Str',
    default       => 'development',
    cmd_aliases   => 'e',
    documentation => 'plack environment [development]',
);

has app_name => (
    traits        => ['Getopt'],
    is            => 'rw',
    isa           => 'Str',
    lazy          => 1,
    builder       => '_build_app_name',
    trigger       => \&_check_app_name,
    cmd_aliases   => 'a',
    documentation => 'set app name',
);

has file_search => (
    traits  => ['NoGetopt'],
    is      => 'rw',
    isa     => 'WK::App::Easy::FileSearch',
    lazy    => 1,
    builder => '_build_file_search',
);

sub _build_app_directory {
    my $self = shift;

    $self->log_debug('build app directory...');

    my $dir = Path::Class::Dir->new('.')->absolute;
    while (scalar($dir->dir_list) > 1) {
        if (-f $dir->file('Makefile.PL')) {
            $self->log_debug("  found Makefile.PL at $dir");
            return $dir;
        }

        $dir = $dir->parent;
    }

    die 'no Makefile.PL found, cannot guess app_directory';
}

sub _build_lib_directory {
    my $self = shift;

    my ($dir) = grep { -d $_ }
                map { $self->app_directory->subdir($_) }
                qw(local perl5lib)
        or die 'neither "local" nor "perl5lib" dir found in app_directory';
    
    return $dir;
}

sub _check_app_name {
    my $self = shift;

    $self->log_debug('check app name...');
}

sub _build_app_name {
    my $self = shift;

    $self->log_debug("build app name (app_directory=${\$self->app_directory})...");

    my $fh = $self->app_directory->file('Makefile.PL')->openr;
    my ($app_name) = map { s{\A .* name .* '(\w+)' .* \z}{$1}ixms; $_; }
                     grep { m{\b name \b}ixms }
                     <$fh>;
    $fh->close;

    die 'app name could not be guessed' if (!$app_name);
    
    $self->log("Guessed app name: $app_name");

    return $app_name;
}

sub _build_file_search {
    my $self = shift;

    return WK::App::Easy::FileSearch->new(
        app => $self,
        search_dirs => [ $self->search_dirs ],
    );
}

sub run {
    my $self = shift;

    $self->log('App-Path:', $self->app_directory, 'Name:', $self->app_name);
    $self->log_debug('extra_argv: ', join(' ', @{$self->extra_argv}));

    $self->search_path(add => "${\$self->app_directory}::WK::App::Easy::Command");

    if (my $command_name = shift @{$self->extra_argv}) {
        $self->log_debug("Command name: $command_name");
        $self->find_and_execute_command($command_name)
            or $self->find_and_execute_binary($command_name);
    } else {
        say STDERR 'No command or executable given. Try "commands" or "help"';
    }
}

sub find_and_execute_command {
    my $self = shift;
    my $command_name = shift;

    if (my $command = $self->find_and_initiate_command($command_name)) {
        $self->log_dryrun("would execute command '$command_name'")
            or do {
                $command->prepare($self, @{$self->extra_argv});
                $command->run($self, @{$self->extra_argv});
            };
        return 1;
    }

    return;
}

sub find_and_initiate_command {
    my $self = shift;
    my $command_name = shift
        or return;

    $self->log_debug("Trying to find command for '$command_name'...");

    my $command_class =
        first { m{:: $command_name \z}xms }
        $self->get_command_classes
            or return;

    $self->log_debug("  Found Command Class: $command_class");

    eval "require $command_class"
        or die "Error loading command class '$command_class'";
    return $command_class->new();
}

sub find_and_execute_binary {
    my $self = shift;
    my $command_name = shift;

    $self->log_debug("Trying to find command for '$command_name'");

    my $executable_and_matching = sub {
        -x $_ &&
        $_->basename =~ m{\A
                          (?: \L${\$self->app_name}\E _)?  # prefix: optional app name
                          \Q$command_name\E                # the requested command
                          (?: \.[a-zA-Z]+)?                # suffix: optional extension
                          \z}xms
    };

    my $executable = $self->file_search->find($executable_and_matching)
        or die "no executable found matching '$command_name'";
    $self->log_debug("Found executable: $executable");

    $self->execute($executable, @{$self->extra_argv});
}

sub execute {
    my $self = shift;
    my $executable = shift;
    my @args = @_;

    $self->log_dryrun("would execute: $executable @args")
        and return;

    $ENV{PERL5LIB}  ||= $self->lib_directory->subdir('lib/perl5')->stringify;
    $ENV{PLACK_ENV} ||= $self->plack_env;

    if (-d $self->app_directory->subdir('config')) {
        $ENV{"\U${\$self->app_name}_CONFIG"} ||= $self->app_directory->subdir('config')->stringify;
        $ENV{"\U${\$self->app_name}_CONFIG_LOCAL_SUFFIX"} ||= $self->config_suffix
            if $self->has_config_suffix;
    }

    chdir $self->app_directory;

    system($executable, @args);
}

sub search_dirs {
    my $self = shift;

    my @app_binary_dirs =
        map { $self->app_directory->subdir($_) }
        qw(script bin);

    my @search_path_dirs;
    if ($self->use_search_path) {
        @search_path_dirs =
            map { Path::Class::Dir->new($_) }
            split(':', $ENV{PATH});
    }

    return
        grep { -d $_ }
            @app_binary_dirs,
            $self->lib_directory->subdir('bin'),
            $self->app_directory,
            @search_path_dirs;
}

__PACKAGE__->meta->make_immutable;

1;
