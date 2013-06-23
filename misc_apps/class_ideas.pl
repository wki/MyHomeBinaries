# some ideas for classes

######### cpanm class -- easy interaction with cpanm
my $cpanm = Cpanm->new(install_dir => '/path/to/x');
$cpanm->install('Catalyst::Runtime');
$cpanm->install('J/JJ/JJNAPIORK/Catalyst-Runtime-5.90042.tar.gz');
$cpanm->install('/path/to/J/JJ/JJNAPIORK/Catalyst-Runtime-5.90042.tar.gz');
$cpanm->install('http://cpan.metacpan.org/authors/id/J/JJ/JJNAPIORK/Catalyst-Runtime-5.90042.tar.gz');

# file search -- locate files matching certain criteria in a list of dirs
my $finder = FileSearch->new(search_dirs => [qw(/path/to/1 /path/to/2)]);
my @files = $finder->find('ls', sub { -x $_[0] });

######### command dispatcher
my $dispatcher = CommandDispatcher->new();
if ($dispatcher->has_command('foo')) {
    # get a CommandDispatcher::Command back, might die
    my $command = $dispatcher->command('foo');
    
    # execute a command
    $dispatcher->command('foo')->run;
}

######### Easy :: run

if (my $command = $self->dispatcher->has_command('...')) {
    $self->dispatcher->command('...')->run;
} elsif ($self->finder(find('...'))) {
    $self->executor(...);
} else {
    # ERROR
}
