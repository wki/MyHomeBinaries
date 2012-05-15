package WK::App::Easy::Command::help;
use Modern::Perl;
use Moose;

extends 'WK::App::Easy::Command';

override run => sub {
    my $self = shift;
    my $app = shift;
    my @args = @_;
    
    if (@args) {
        my $command = $app->find_and_initiate_command($args[0]);
        if ($command && $command->documentation) {
            say $command->documentation;
            return;
        }
    }
    
    say <<EOF;
easy -- do common tasks in an easy way

USAGE
    easy [general options] command [command_options]

GENERAL OPTIONS
    --usage or -h or -? for a list of general options

BUILT IN COMMANDS
    help            this help
    help <command>  additional help for a given command
    commands        lists all commands and binaries available
    cpanm           downloads and runs cpanm

COMMANDS
    first, MyApp::App::Easy::Command:: and App::Easy::Command:: namespaces
    are searched for a module having the required (typical lower case) command
    class.

    If no command is found there, the script, bin and perl5lib/bin directories
    of your app are searched for a command. The command name may be prefixed
    with the app_name and have an extension.

EOF
};

1;
