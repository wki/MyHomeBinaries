package Provision::DSL::Entity::_OSX::Service;
use Moose;
use namespace::autoclean;

extends 'Provision::DSL::Entity::Service';

my $LAUNCHCTL = '/bin/launchctl';

sub _build_path {
    warn "OVERLOADED build Path (Service)";
    
    ### TODO: non-root users have different paths!
    return "/Library/LaunchDaemons/${\$self->name}.plist";
}

around is_present => sub {
    my ($orig, $self) = @_;

    return $self->command_succeeds($LAUNCHCTL, list => $self->name)
        && $self->$orig();
};

after create => sub {
    my $self = shift;

    $self->system_command($LAUNCHCTL, load => '-w' => $self->path);
};

after change => sub {
    my $self = shift;

    $self->system_command($LAUNCHCTL, stop => $self->name);
};

before remove => sub {
    my $self = shift;

    $self->system_command($LAUNCHCTL, unload => '-w' => $self->path);
};

__PACKAGE__->meta->make_immutable;
1;
