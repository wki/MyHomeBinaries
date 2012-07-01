package Provision::DSL::Entity::Perlbrew;
use Moose;
use LWP::Simple;
use Povision::DSL;
use namespace::autoclean;

extends 'Provision::DSL::Entity::Compound';
# with 'Provision::Role::User';

has install_cpanm => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
);

has install_perl => (
    is => 'ro',
    isa => 'Str', # maybe allow 'Str | ArrayRef[Str]'
    required => 1,
);

has switch_to_perl => (
    is => 'ro',
    isa => 'Str',
);

sub _build_user { 
    return $_[0]->name 
}

sub _build_children {
    my $self = shift;
    
    return [
        $self->entity(Perlbrew_Install => {user => $self->user, parent => $self}),
        $self->entity(Perlbrew_Cpanm =>   {user => $self->user, parent => $self}),
        $self->entity(Perlbrew_Perl =>    {user => $self->user, parent => $self, install => $self->install_perl}),
        $self->entity(Perlbrew_Switch =>  {user => $self->user, parent => $self, switch => $self->switch_to_perl}),
    ];
}




# sub create {
#     my $self = shift;
#     
#     $self->log_dryrun("would install perlbrew for User '${\$self->user->name}' " .
#                       "into '${\$self->user->home_directory}'")
#         and return;
#     
#     my $perlbrew_install = get('http://install.perlbrew.pl')
#         or die 'could not download perlbrew';
#     
#     $self->pipe_into_command($perlbrew_install, 
#                              '/usr/bin/su', $self->user->name);
# }

__PACKAGE__->meta->make_immutable;
1;
