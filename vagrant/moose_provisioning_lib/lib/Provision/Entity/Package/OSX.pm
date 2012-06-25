package Provision::Entity::Package::OSX;
use Moose;
use namespace::autoclean;
extends 'Provision::Entity::Package';

our $PORT = '/opt/local/bin/port';

sub _build_latest_version {
    my $self = shift;

    my ($latest_version) =
        map { m{\A \s* \S+ \s+ (\S+)}xms ? $1 : () }
        `$PORT info --line ${\$self->name}`;

    $self->app->log_debug("Latest version for '${\$self->name}'",
                          $latest_version // '(not available)');

    return $latest_version;
}

sub must_be_executable {
    die 'MacPorts not installed' if !-x $PORT;
}

before execute => sub {
    my $self = shift;

    my ($port_version) =
        map { m{\A \s* \Q${\$self->name}\E \s+ (\S+)_\d+ .* active}xms ? $1 : () }
        `$PORT installed`;

    $self->app->log_debug("Port info for '${\$self->name}'",
                          $port_version // '(not installed)');

    $self->installed_version($port_version) if $port_version;
};

sub create {
    my $self = shift;
    
    $self->system_command($PORT, install => $self->name);
    
    $self->installed_version($self->latest_version);
}

__PACKAGE__->meta->make_immutable;
1;
