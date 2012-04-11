package WK::App::InstallModuleCollections;
use Modern::Perl;
use Moose;
use MooseX::Types::Path::Class qw(File Dir);
use JSON;
use namespace::autoclean;

extends 'WK::App';
with 'MooseX::Getopt';

has temp_dir => (
    traits => ['Getopt'],
    is => 'ro',
    isa => Dir,
    required => 1,
    lazy => 1,
    coerce => 1,
    default => "$ENV{HOME}/tmp/modules",
);

has cpanm => (
    traits => ['Getopt'],
    is => 'ro',
    isa => File,
    required => 1,
    lazy => 1,
    coerce => 1,
    default => "$ENV{HOME}/bin/cpanm",
);

has cpanm_options => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'ArrayRef[Str]',
    required => 1,
    lazy => 1,
    coerce => 1,
    default => sub { ['--mirror', "$ENV{HOME}/minicpan", '--mirror-only'] },
);


sub run {
    my $self = shift;
    
    # for every module in list of modules
    #     install every single module
    #     find temp_dir/lib/perl5/*/<<distribution_name>>/MYMETA.json
    #     read json file and add distribution + Version to list of modules
    # create Table-Of-Contents File
    #     Name, creation date
    #     List of Distributions and Version
    # fire pdf-generation script
}

__PACKAGE__->meta->make_immutable;
1;

__END__

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
