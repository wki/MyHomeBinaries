package Provision::Entity::Package::OSX;
use Moose;
use namespace::autoclean;
extends 'Provision::Entity::Package';

our $PORT = '/opt/local/bin/port';

before execute => sub {
    my $self = shift;
    
    my ($port_version) = map { m{\A \s* \Q${\$self->name}\E \s+ (\S+) .* active}xms ? $1 : () }
                      `$PORT installed`;
    
    $self->app->log_debug("Port info for '${\$self->name}'", $port_version // '(not installed)');
    
    $self->installed_version($port_version) if $port_version;
};

__PACKAGE__->meta->make_immutable;
1;
