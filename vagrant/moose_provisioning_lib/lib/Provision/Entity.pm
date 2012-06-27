package Provision::Entity;
use Moose;
use IPC::Open3 'open3';
use autodie ':all';
use namespace::autoclean;

has name => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    default => '',   # allow empty names (eg Nginx)
);

has app => (
    is => 'ro',
    isa => 'Provision::App',
    required => 1,
    handles => [qw(verbose dryrun
                   log log_dryrun log_debug)],
);

has call_on_create => (
    is => 'ro',
    isa => 'CodeRef',
    init_arg => 'on_create',
    predicate => 'has_create_callback',
);

has call_on_change => (
    is => 'ro',
    isa => 'CodeRef',
    init_arg => 'on_change',
    predicate => 'has_change_callback',
);

sub type {
    my $self = shift;

    my $type = ref $self;
    $type =~ s{\A Provision::Entity:: (.+?) (?: ::.*)? \z}{$1}xms;

    return $type;
}

sub execute {
    my $self = shift;
    
    $self->must_be_executable;

    if (!$self->is_present || !$self->is_current) {
        my $was_present_before_create = $self->is_present;

        $self->log("create: ${\$self->type} '${\$self->name}'");

        $self->create;
        
        $self->call_on_create->() if $self->has_create_callback && !$was_present_before_create;
        $self->call_on_change->() if $self->has_change_callback;
    } else {
        $self->log_debug("is_present: ${\$self->type} (${\$self->name})");
    }

    return $self;
}

sub system_command {
    my $self = shift;

    return $self->pipe_into_command('', @_);
}

sub pipe_into_command {
    my $self = shift;
    my $input_text = shift;
    my @system_args = @_;
    
    $self->log_dryrun('would execute:', @system_args) and return;
    $self->log_debug('execute:', @system_args);
    
    my $pid = open3(my $in, my $out, my $err, @system_args);
    print $in $input_text // ();
    close $in;

    my $text = join '', <$out>;
    waitpid $pid, 0;
    
    my $status = $? >> 8;
    die "command '$system_args[0]' failed. status: $status" if $status;
    
    return $text;
}

#
# these are typically overloaded:
#
sub must_be_executable {} # execption if not executable
sub is_present { 0 }
sub is_current { 1 }
sub create {}

__PACKAGE__->meta->make_immutable;
1;
