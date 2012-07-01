package Provision::App;
use Moose;
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

has _resource_class_for => (
    is => 'rw',
    isa => 'HashRef',
);

sub resource {
    my $self = shift;
    my $resource = shift;
    my $name = shift;
    
    my $class = $self->_resource_class_for->{$resource}
        or die "no class for resource '$resource' found";
    
    return $class->new( { app => $self, name => $name, @_ } );
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

__PACKAGE__->meta->make_immutable;
1;
