package Provision::Entity::Perlbrew;
use Moose;
use LWP::Simple;
use namespace::autoclean;

extends 'Provision::Entity';
with 'Provision::Role::User';

has install_cpanm => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
);

has install_perl => (
    is => 'ro',
    isa => 'Str | ArrayRef[Str]',
    required => 1,
);

has switch_to_perl => (
    is => 'ro',
    isa => 'Str',
);

sub _build_user { 
    return $_[0]->name 
}

sub create {
    my $self = shift;
    
    $self->log_dryrun("would install perlbrew for User '${\$self->user->name}' " .
                      "into '${\$self->user->home_directory}'")
        and return;
    
    my $perlbrew_install = get('http://install.perlbrew.pl')
        or die 'could not download perlbrew';
    
    $self->pipe_into_command($perlbrew_install, 
                             '/usr/bin/su', $self->user->name);
}

sub is_present {
    -f $_[0]->user->home_directory->file('perl5/perlbrew/bin/perlbrew');
}

__PACKAGE__->meta->make_immutable;
1;
