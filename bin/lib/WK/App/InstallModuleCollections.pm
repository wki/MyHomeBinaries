package WK::App::InstallModuleCollections;
use Modern::Perl;
use Moose;
use MooseX::Types::Path::Class qw(File Dir);
use JSON;
use File::Temp ();
use Config;
use autodie ':all';
use namespace::autoclean;

extends 'WK::App';
with 'MooseX::Getopt';

has temp_dir => (
    traits => ['NoGetopt'],
    is => 'ro',
    isa => Dir,
    required => 1,
    lazy_build => 1,
    coerce => 1,
);

has cpanm => (
    traits => ['Getopt'],
    is => 'ro',
    isa => File,
    required => 1,
    lazy => 1,
    coerce => 1,
    default => "$ENV{HOME}/bin/cpanm",
    documentation => 'path to the cpanm binary [$HOME/bin/cpanm]',
);

has collection => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Str',
    required => 1,
    cmd_aliases => 'c',
    documentation => 'the collection of modules to generate documentation for. ' .
                     'One of catalyst, moose, dbic',
);

has modules => (
    traits => ['NoGetopt'],
    is => 'ro',
    isa => 'ArrayRef[Str]',
    required => 1,
    lazy_build => 1,
);

has cpanm_options => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'ArrayRef[Str]',
    required => 1,
    lazy => 1,
    cmd_aliases => 'o',
    default => sub { ['--mirror', "$ENV{HOME}/minicpan", '--mirror-only'] },
);

has installed_modules => (
    traits => ['NoGetopt', 'Hash'],
    is => 'rw',
    isa => 'HashRef[Str]', # module => version
    required => 1,
    default => sub { {} },
    handles => {
        add_module => 'set',
    },
);


sub run {
    my $self = shift;

    $self->log_debug('Temp Dir:', $self->temp_dir);
    
    $self->install_module($_) for @{$self->modules};
    $self->collect_installed_modules;
    $self->create_toc;
    # create Table-Of-Contents File
    #     Name, creation date
    #     List of Distributions and Version
    # fire pdf-generation script
}

sub _build_modules {
    my $self = shift;

    [
        grep { !m{\A (\[.* | \s*) \z}xms }
        grep { m{\A \[ \Q${\$self->collection}\E \] \s* \z}ixms
               ...
               m{\A \[}xms }
        map { chomp; $_ }
        <DATA>
    ]
}

sub _build_temp_dir {
    my $self = shift;
    
    File::Temp::tempdir(CLEANUP => 1);
}

sub install_module {
    my $self = shift;
    my $module = shift;
    
    $self->log_dryrun("would install $module") and return;
    $self->log("Installing $module");
    
    # cpanm still generates some output. Currently we just ignore this fact...
    system $self->cpanm,
           @{$self->cpanm_options},
           '-n',
           '-q',
           '-L' => $self->temp_dir,
           $module;
}

sub collect_installed_modules {
    my $self = shift;
    
    my $meta_dir = $self->temp_dir->subdir("lib/perl5/$Config{archname}/.meta");
    foreach my $dist_dir (grep { -d } $meta_dir->children) {
        $self->log_debug("checking dist-dir $dist_dir");
        
        my $module_info = decode_json(scalar $dist_dir->file('install.json')->slurp);
        
        $self->log("Module: $module_info->{name}, Version: $module_info->{version}");
        
        $self->add_module($module_info->{name} => $module_info->{version});
    }
}

sub create_toc {
    my $self = shift;
    
    my $toc = <<POD;
=head1 TABLE OF CONTENTS

TODO: name of thing generated

=head1 CREATED

TODO: date of creation

=head1 MODULES

=over

POD

    ### TODO: filter!!!
    $toc .= "=item $_ (${\$self->installed_modules->{$_}})\n\n" for keys %{$self->installed_modules};

    $toc .= <<POD;

=back

=cut
POD

    return $toc;
}

__PACKAGE__->meta->make_immutable;
1;

__DATA__
[catalyst]

Catalyst::Action::REST
Catalyst::Action::RenderView
Catalyst::Action::RenderView::ErrorHandler
Catalyst::ActionRole::DetachOnDie
Catalyst::Authentication::Credential::HTTP
Catalyst::Component::ACCEPT_CONTEXT
Catalyst::Component::InstancePerContext
Catalyst::Controller::ActionRole
Catalyst::Controller::Combine
Catalyst::Controller::HTML::FormFu
Catalyst::Controller::Imager
Catalyst::Devel
Catalyst::Manual
Catalyst::Model::Adaptor
Catalyst::Model::DBIC::Schema
Catalyst::Model::REST
Catalyst::Model::Redis
Catalyst::Plugin::Authentication
Catalyst::Plugin::Authentication::Credential::HTTP
Catalyst::Plugin::Authorization::Roles
Catalyst::Plugin::AutoCRUD
Catalyst::Plugin::ConfigLoader
Catalyst::Plugin::DefaultEnd
Catalyst::Plugin::I18N
Catalyst::Plugin::Session
Catalyst::Plugin::Session::State::Cookie
Catalyst::Plugin::Session::Store::File
Catalyst::Plugin::Static::Simple
Catalyst::Plugin::Unicode
Catalyst::Plugin::UploadProgress
Catalyst::Plugin::XSendFile
Catalyst::Runtime
Catalyst::View::ByCode
Catalyst::View::Email
Catalyst::View::JSON
Catalyst::View::SVG::TT::Graph
Catalyst::View::TT
CatalystX::Component::Traits

PSGI
Plack
Plack::Middleware::ForceEnv
Plack::Middleware::ReverseProxy
Plack::Middleware::ServerStatus::Lite
Plack::Test::ExternalServer
Starman
Test::WWW::Mechanize
Test::WWW::Mechanize::Catalyst
Test::WWW::Mechanize::PSGI

HTML::FormFu
HTML::FormFu::Model::DBIC



[dbic]

DBIx::Class
DBIx::Class::Candy
DBIx::Class::DeploymentHandler
DBIx::Class::DynamicDefault
DBIx::Class::Helpers
DBIx::Class::IntrospectableM2M
DBIx::Class::Schema::Loader
DBIx::Class::Schema::PopulateMore
DBIx::Class::TimeStamp
DBIx::Class::UUIDColumns
SQL::Abstract
SQL::Translator

Test::DBIx::Class



[moose]

Moose
Moose::Autobox
MooseX::Aliases
MooseX::App::Cmd
MooseX::Attribute::ENV
MooseX::AttributeHelpers
MooseX::ConfigFromFile
MooseX::Daemonize
MooseX::Emulate::Class::Accessor::Fast
MooseX::Getopt
MooseX::Has::Options
MooseX::LazyRequire
MooseX::MarkAsMethods
MooseX::MethodAttributes
MooseX::NonMoose
MooseX::OneArgNew
MooseX::Params::Validate
MooseX::Role::Parameterized
MooseX::Role::WithOverloading
MooseX::SemiAffordanceAccessor
MooseX::SetOnce
MooseX::Singleton
MooseX::Traits::Pluggable
MooseX::Types
MooseX::Types::Common
MooseX::Types::LoadableClass
MooseX::Types::Path::Class
MooseX::Types::Perl
