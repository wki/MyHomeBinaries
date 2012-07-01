package Provision::DSL::App;
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

has _entity_class_for => (
    is => 'rw',
    isa => 'HashRef',
);

sub entity {
    my $self   = shift;
    my $entity = shift;
    my $name   = shift;
    
    my $class = $self->_resource_class_for->{$entity}
        or die "no class for entity '$entity' found";
    
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
