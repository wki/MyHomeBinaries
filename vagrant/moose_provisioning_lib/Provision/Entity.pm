package Provision::Entity;
use Moose;
use namespace::autoclean;

has name => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    default => '',
);

has app => (
    is => 'ro',
    isa => 'Provision::App',
    required => 1,
    handles => {
        verbose => 'verbose',
        dryrun  => 'dryrun',
    },
);

sub type {
    my $self = shift;

    my $type = ref $self;
    $type =~ s{\A .* ::}{}xms;
    
    return $type;
}

sub log {
    my $self = shift;
    $self->_log_if($self->app->verbose || $self->app->debug, @_);
}

sub log_debug {
    my $self = shift;
    $self->_log_if($self->app->debug, 'DEBUG: ', @_);
}

sub log_dryrun {
    my $self = shift;
    $self->_log_if($self->app->dryrun, @_);
}

sub _log_if {
    my $self = shift;
    my $condition = shift;

    say STDERR join(' ', @_) if $condition;

    return $condition;
}

sub execute {
    my $self = shift;

    if (!$self->is_present) {
        $self->log_debug("must create ${\$self->type} (${\$self->name})");
        $self->create;
    } else {
        $self->log_debug("is_present ${\$self->type} (${\$self->name})");
    }
    
    return $self;
}

sub is_present { 0 }

sub create { }

__PACKAGE__->meta->make_immutable;
1;
