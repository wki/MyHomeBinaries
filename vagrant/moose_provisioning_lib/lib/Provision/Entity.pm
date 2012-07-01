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

foreach my $event (qw(before_create before_change before_remove
                      after_create after_change after_remove)) {
    has "call_$event" => (
        is => 'ro',
        isa => 'CodeRef',
        init_arg => $event,
        predicate => "has_${$event}_callback",
    );
}

sub type {
    my $self = shift;

    my $type = ref $self;
    $type =~ s{\A Provision::Entity:: (.+?) (?: ::.*)? \z}{$1}xms;

    return $type;
}

sub execute {
    my $self = shift;

    $self->must_meet_requirements;

    if ($self->has_required_callback && !$self->required->()) {
        $self->log_debug("not required to change: ${\$self->type} (${\$self->name})");
    } elsif (!$self->is_present) {
        $self->_execute_with_hooks('not present before');
    } elsif (!$self->is_current) {
        $self->_execute_with_hooks('not current');
    } elsif ($self->has_sufficient_callback && !$self->sufficient->()) {
        $self->_execute_with_hooks('not sufficient');
    } else {
        $self->log_debug("no need to change: ${\$self->type} (${\$self->name})");
    }
    
    # TODO: post-check?

    return $self;
}

sub _execute {
    my ($self, $triggered_by) = @_;

    my $was_present_before_create = $self->is_present;

    $self->log("create: ${\$self->type} '${\$self->name}' - trigger: $triggered_by");

    $self->call_before_create->() if $self->has_before_create_callback && !$was_present_before_create;
    $self->call_before_change->() if $self->has_before_change_callback;

    $self->create;

    $self->call_after_create->() if $self->has_after_create_callback && !$was_present_before_create;
    $self->call_after_change->() if $self->has_after_change_callback;
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
sub must_meet_requirements {} # execption if not executable
sub is_present { 0 }
sub is_current { 1 }
sub create {}

__PACKAGE__->meta->make_immutable;
1;
