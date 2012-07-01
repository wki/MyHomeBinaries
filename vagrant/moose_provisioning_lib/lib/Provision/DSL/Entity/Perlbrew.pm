package Provision::DSL::Entity::Perlbrew;
use Moose;
use LWP::Simple;
use namespace::autoclean;

extends 'Provision::DSL::Entity';
# with 'Provision::Role::User';

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

# alternativ -- extends 'Compound';
sub BUILD {
    my $self = shift;

    $self->add_child(
        $self->app->entity(PerlbrewInstall => $self->name, { }),
    );
    
    # besser -- nicht ganz sauber:
    $self->add_entity('Perlbrew::Install', { only_if => '???' });
    
    
    
    # was ich eigentlich will:
    $self->add_entity(Execute => Url('http://perlbrew.pl'),
                      user    => $self->user,
                      not_if  => FileExists($self->perlbrew));
    
    if ($self->install_cpanm) {
        $self->add_entity(Execute => $self->perlbrew,
                          args    => 'install-cpanm',
                          not_if  => FileExists($self->cpanm))
    }
    
    # install perls
    
    # switch

}




around is_present => sub {
    my ($orig, $self) = @_;
    
    return -f $self->user->home_directory->file('perl5/perlbrew/bin/perlbrew')
         # && cpanm_install_status_is_ok
         # && all_requested_perl_versions_installed
         # && correct_perl_version_switched
           && $self->$orig();
};

after ['create', 'change'] => sub {
    
    # install perlbrew if not yet there
    # install cpanm if needed
    # install missing perl versions
    # switch to wanted perl version
};

after remove => sub {
    # remove perlbrew directory
};

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
