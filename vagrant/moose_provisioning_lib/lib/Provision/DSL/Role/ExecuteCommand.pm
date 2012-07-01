package Provision::DSL::Role::ExecuteCommand;
use Moose::Role;
use Provision::DSL::Types;
use Try::Tiny;
use IPC::Open3 'open3';

has path => (
    is => 'ro',
    isa => 'PathClassFile',
    coerce => 1,
    lazy_build => 1,
);

# _build_path in consuming class!!!

sub execute_command {
    my $self = shift;
    my $input_text = shift;

    my @args; ### FIXME: fill!
    my $pid = open3(my $in, my $out, my $err,
                    $self->path->stringify,
                    @args);
    print $in $input_text // ();
    close $in;

    my $text = join '', <$out>;
    waitpid $pid, 0;

    my $status = $? >> 8;
    die "command '${\$self->path}' failed. status: $status" if $status;

    return $text;
}

sub executes_successful {
    my $self = shift;
    
    my $result = 1;
    try {
        $self->execute_command;
    } catch {
        $result = 0;
    };
    
    return $result;
}


no Moose::Role;
1;