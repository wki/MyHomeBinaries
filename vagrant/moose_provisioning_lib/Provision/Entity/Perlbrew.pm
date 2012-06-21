package Provision::Entity::Perlbrew;
use Moose;
use LWP::Simple;
use IPC::Open3 'open3';
use namespace::autoclean;
extends 'Provision::Entity';

has user_name => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    lazy_build => 1,
);

has _user => (
    is => 'ro',
    isa => 'Provision::Entity::User',
    required => 1,
    lazy_build => 1,
);

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

sub _build_user_name { $_[0]->name }
sub _build__user { $_[0]->app->resource(User => $_[0]->user_name) }

sub create {
    my $self = shift;
    
    $self->log_dryrun("would install perlbrew for User '${\$self->user_name}' into '${\$self->_user->home_directory}'")
        and return;
    
    my $perlbrew_install = get('http://install.perlbrew.pl')
        or die 'could not download perlbrew';
    
    $self->pipe_into_command($perlbrew_install, 
                             '/usr/bin/su', $self->user_name);
}

sub is_present {
    -f $_[0]->_user->home_directory->file('perl5/perlbrew/bin/perlbrew');
}

__PACKAGE__->meta->make_immutable;
1;
