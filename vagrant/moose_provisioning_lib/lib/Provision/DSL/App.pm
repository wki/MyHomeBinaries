package Provision::DSL::App;
use Moose;
use IPC::Open3 'open3';
use Try::Tiny;
use namespace::autoclean;
with 'MooseX::Getopt::Strict';

has verbose => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Bool',
    default => 0,
    cmd_aliases => 'v',
);

has debug => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Bool',
    default => 0,
);

has dryrun => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Bool',
    default => 0,
    cmd_aliases => 'n',
);

has _entity_class_for => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
);

sub entity {
    my $self   = shift;
    my $entity = shift;
    
    my %args = (app => $self);
    $args{name} = shift if !ref $_[0];
    %args = (%args, ref $_[0] eq 'HASH' ? %{$_[0]} : @_);
    
    my $class = $self->_entity_class_for->{$entity}
        or die "no class for entity '$entity' found";
    
    return $class->new(\%args);
}

sub log {
    my $self = shift;
    $self->_log_if($self->verbose || $self->debug, @_);
}

sub log_debug {
    my $self = shift;
    $self->_log_if($self->debug, 'DEBUG:', @_);
}

sub log_dryrun {
    my $self = shift;
    $self->_log_if($self->dryrun, @_);
}

sub _log_if {
    my $self = shift;
    my $condition = shift;

    say STDERR join(' ', @_) if $condition;

    return $condition;
}

sub command_succeeds {
    my $self = shift;
    my @args = @_;
    
    my $result;
    try {
        $self->system_command(@args);
        $result = 1;
    };
    
    return $result;
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

__PACKAGE__->meta->make_immutable;
1;
