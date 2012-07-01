package Provision::DSL::Entity::Package::OSX;
use Moose;
use namespace::autoclean;

extends 'Provision::DSL::Entity::Package';

my $PORT = '/opt/local/bin/port';

around is_present => sub {
    my ($orig, $self) = @_;

    return $self->_installed_version && $self->$orig();
};

after ['create', 'change'] => sub {
    my $self = shift;

    $self->system_command($PORT, install => $self->name);
};

after remove => sub {
    my $self = shift;

    $self->system_command($PORT, uninstall => $self->name);
};

sub _installed_version {
    my $self = shift;

    my ($installed_version) =
    map { m{\A \s* \Q${\$self->name}\E \s+ (\S+)_\d+ .* active}xms ? $1 : () }
    `$PORT installed`;

    return $installed_version;
}

sub _latest_version {
    my $self = shift;

    my ($latest_version) =
        map { m{\A \s* \S+ \s+ (\S+)}xms ? $1 : () }
        `$PORT info --line ${\$self->name}`;

    return $latest_version;
}

__PACKAGE__->meta->make_immutable;
1;
