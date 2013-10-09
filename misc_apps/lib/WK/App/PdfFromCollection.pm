package WK::App::PdfFromCollection;
use Modern::Perl;
use Moose;
use MooseX::Types::Path::Class 'File';
use JSON;
use Config;
use DateTime;
use WK::App::ConvertPod2Pdf;
use autodie ':all';
use namespace::autoclean;

extends 'WK::App';
with 'MooseX::Getopt',
     'WK::App::Role::Cpanm';

has target_file => (
    traits => ['Getopt'],
    is => 'rw',
    isa => File,
    required => 1,
    lazy_build => 1,
    coerce => 1,
    cmd_flag => 'save_to',
    cmd_aliases => 'f',
    documentation => 'A File to save to [$HOME/Desktop/<<collection>>.pdf]',
);

has collection => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Str',
    required => 1,
    cmd_aliases => 'c',
    documentation => 'the collection of modules to generate documentation for. ' .
                     'One of ' . join(', ', keys %{__info()}),
);

has modules => (
    traits => ['NoGetopt'],
    is => 'ro',
    isa => 'ArrayRef[Str]',
    required => 1,
    lazy_build => 1,
);

has filter_packages => (
    traits => ['NoGetopt'],
    is => 'ro',
    isa => 'ArrayRef[Str]',
    required => 1,
    lazy_build => 1,
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

has toc_file => (
    traits => ['NoGetopt'],
    is => 'rw',
    isa => File,
    lazy_build => 1,
);

has pdf_converter => (
    traits => ['NoGetopt'],
    is => 'rw',
    isa => 'WK::App::ConvertPod2Pdf',
    lazy_build => 1,
);

sub run {
    my $self = shift;

    $self->log_debug('(Temp) Install Base:', $self->install_base);

    $self->install_module($_) for @{$self->modules};
    $self->collect_installed_modules;
    $self->build_toc;
    $self->create_pdf;
}

sub _build_modules {
    my $self = shift;

    _info_for_collection($self->collection)->{modules}
}

sub _build_filter_packages {
    my $self = shift;

    _info_for_collection($self->collection)->{filter}
}

sub _build_target_file {
    my $self = shift;

    "$ENV{HOME}/Desktop/${\$self->collection}.pdf"
}

sub _build_toc_file {
    my $self = shift;

    $self->lib_directory
         ->file($self->collection . '.pod');
}

sub _build_pdf_converter {
    my $self = shift;

    WK::App::ConvertPod2Pdf->new(
        filter_packages => $self->filter_packages,
        directory       => $self->lib_directory,
        target_file     => $self->target_file,
        toc_file        => $self->toc_file,
        verbose         => $self->verbose,
        debug           => $self->debug,
    );
}

sub install_module {
    my $self = shift;
    my $module = shift;

    $self->log_dryrun("would install $module") and return;
    $self->log("Installing $module");

    $self->run_cpanm($module);
}

sub collect_installed_modules {
    my $self = shift;

    $self->log_dryrun("would collect module versions") and return;
    $self->log('collecting module versions');

    my $meta_dir = $self->lib_directory->subdir("$Config{archname}/.meta");
    foreach my $dist_dir (grep { -d } $meta_dir->children) {
        $self->log_debug("checking dist-dir $dist_dir");

        my $module_info = decode_json(scalar $dist_dir->file('install.json')->slurp);

        $self->log("Module: $module_info->{name}, Version: $module_info->{version}");

        $self->add_module($module_info->{name} => $module_info->{version});
    }
}

sub build_toc {
    my $self = shift;

    $self->log_dryrun("would create toc") and return;
    $self->log('creating toc');

    my $now = DateTime->now;

    my $toc = <<POD;
=head1 TABLE OF CONTENTS

${\$self->collection} - related modules

=head1 CREATED

${\$now->dmy} ${\$now->hms} by $ENV{USER}

=head1 MODULES

=over

POD

    $toc .= "=item $_ (${\$self->installed_modules->{$_}})\n\n"
        for sort @{$self->modules};

    $toc .= <<POD;

=back

=cut
POD

    my $toc_fh = $self->toc_file->openw;
    print $toc_fh $toc;
    $toc_fh->close;
}

sub create_pdf {
    my $self = shift;

    $self->log_dryrun('would create pdf') and return;
    $self->log('creating pdf');

    $self->pdf_converter->run;
}

sub _info_for_collection {
    my $collection = shift;

    my $info = __info()->{$collection}
        or die "Collection '$collection' not found. Available are: " .
               join(', ', keys %{__info()});
    return $info;
}

sub __info {
    {
        catalyst => {
            filter => [qw(Catalyst CatalystX
                          Test::WWW
                          HTML::Form)],
            modules => [qw(Catalyst::Action::FromPSGI
                           Catalyst::Action::REST
                           Catalyst::Action::RenderView
                           Catalyst::Action::RenderView::ErrorHandler
                           Catalyst::Action::RenderView::ErrorHandler::Action::Email
                           Catalyst::ActionRole::CheckTrailingSlash
                           Catalyst::ActionRole::DetachOnDie
                           Catalyst::ActionRole::ExpiresHeader
                           Catalyst::ActionRole::MatchHost
                           Catalyst::ActionRole::MatchRequestMethod
                           Catalyst::ActionRole::MatchRequestAccepts
                           Catalyst::ActionRole::NotCacheableHeaders
                           Catalyst::ActionRole::PseudoCache
                           Catalyst::ActionRole::QueryParameter
                           Catalyst::ActionRole::RequireSSL
                           Catalyst::ActionRole::Tabs
                           Catalyst::Authentication::Credential::HTTP
                           Catalyst::Authentication::Realm::Adaptor
                           Catalyst::Component::ACCEPT_CONTEXT
                           Catalyst::Component::InstancePerContext
                           Catalyst::Controller::Accessors
                           Catalyst::Controller::ActionRole
                           Catalyst::Controller::Combine
                           Catalyst::Controller::DBIC::API
                           Catalyst::Controller::DBIC::Transaction
                           Catalyst::Controller::HTML::FormFu
                           Catalyst::Controller::FormBuilder
                           Catalyst::Controller::Imager
                           Catalyst::Controller::POD
                           Catalyst::Devel
                           Catalyst::DispatchType::Regex
                           Catalyst::Helper::AuthDBIC
                           Catalyst::Helper::DBIC::DeploymentHandler
                           Catalyst::Helper::HTML::FormHandler::Scripts
                           Catalyst::Helper::View::Bootstrap
                           Catalyst::Manual
                           Catalyst::Model::Adaptor
                           Catalyst::Model::DBIC::Schema
                           Catalyst::Model::File
                           Catalyst::Model::Memcached
                           Catalyst::Model::MultiAdaptor
                           Catalyst::Model::Proxy
                           Catalyst::Model::REST
                           Catalyst::Model::Redis
                           Catalyst::Model::Riak
                           Catalyst::Plugin::Alarm
                           Catalyst::Plugin::Authentication
                           Catalyst::Plugin::Authentication::Credential::HTTP
                           Catalyst::Plugin::Authorization::Roles
                           Catalyst::Plugin::AutoCRUD
                           Catalyst::Plugin::Bread::Board
                           Catalyst::Plugin::Cache
                           Catalyst::Plugin::Cache::FastMmap
                           Catalyst::Plugin::Cache::HTTP
                           Catalyst::Plugin::Cache::Memcached
                           Catalyst::Plugin::Cache::Store::FastMmap
                           Catalyst::Plugin::ConfigLoader
                           Catalyst::Plugin::EnableMiddleware
                           Catalyst::Plugin::ErrorCatcher
                           Catalyst::Plugin::I18N
                           Catalyst::Plugin::Log::Dispatch
                           Catalyst::Plugin::Session
                           Catalyst::Plugin::Session::State::Cookie
                           Catalyst::Plugin::Session::Store::File
                           Catalyst::Plugin::Session::Store::DBIC
                           Catalyst::Plugin::Session::Store::FastMmap
                           Catalyst::Plugin::Session::Store::Redis
                           Catalyst::Plugin::Session::Store::Memcached
                           Catalyst::Plugin::Session::PSGI
                           Catalyst::Plugin::Static::Simple
                           Catalyst::Plugin::Static::Simple::ByClass
                           Catalyst::Plugin::StatusMessage
                           Catalyst::Plugin::Unicode
                           Catalyst::Plugin::UploadProgress
                           Catalyst::Plugin::XSendFile
                           Catalyst::Runtime
                           Catalyst::TraitFor::Context::PSGI::FindEnv
                           Catalyst::TraitFor::Controller::Breadcrumb::Followed
                           Catalyst::TraitFor::Controller::DBIC::DoesPaging
                           Catalyst::TraitFor::Controller::DoesExtPaging
                           Catalyst::TraitFor::Controller::LocaleSelect
                           Catalyst::TraitFor::Controller::PermissionCheck
                           Catalyst::TraitFor::Controller::Ping
                           Catalyst::TraitFor::Controller::RenderView
                           Catalyst::TraitFor::Log::Audio
                           Catalyst::TraitFor::Model::DBIC::Schema::QueryLog
                           Catalyst::TraitFor::Model::DBIC::Schema::QueryLog::AdoptPlack
                           Catalyst::TraitFor::Model::DBIC::Schema::RequestConnectionPool
                           Catalyst::TraitFor::Model::DBIC::Schema::ResultRoles
                           Catalyst::TraitFor::Model::DBIC::Schema::WithCurrentUser
                           Catalyst::TraitFor::Request::BrowserDetect
                           Catalyst::TraitFor::Request::DecodedParams
                           Catalyst::TraitFor::Request::GeoIP
                           Catalyst::TraitFor::Request::Params::Hashed
                           Catalyst::TraitFor::Request::PerLanguageDomains
                           Catalyst::TraitFor::Request::Plack::Session
                           Catalyst::TraitFor::Request::ProxyBase
                           Catalyst::TraitFor::Request::REST::ForBrowsers::AndPJAX
                           Catalyst::TraitFor::Request::XMLHttpRequest
                           Catalyst::TraitFor::View::MarkupValidation
                           Catalyst::View::ByCode
                           Catalyst::View::CSS::Minifier::XS
                           Catalyst::View::CSV
                           Catalyst::View::Download
                           Catalyst::View::Email
                           Catalyst::View::GD
                           Catalyst::View::GD::Thumbnail
                           Catalyst::View::GD::Barcode
                           Catalyst::View::GD::Barcode::QRcode
                           Catalyst::View::Haml
                           Catalyst::View::JavaScript::Minifier::XS
                           Catalyst::View::JSON
                           Catalyst::View::Markdown
                           Catalyst::View::PDF::API2
                           Catalyst::View::PDF::Reuse
                           Catalyst::View::PDFBoxer
                           Catalyst::View::PNGTTGraph
                           Catalyst::View::RRDGraph
                           Catalyst::View::SVG::TT::Graph
                           Catalyst::View::Thumbnail::Simple
                           Catalyst::View::TT
                           Catalyst::View::Wkhtmltopdf
                           CatalystX::AppBuilder
                           CatalystX::AuthenCookie
                           CatalystX::CMS
                           CatalystX::CRUD
                           CatalystX::CRUD::Controller::REST
                           CatalystX::CRUD::Controller::RHTMLO
                           CatalystX::CRUD::Model::RDBO
                           CatalystX::CRUD::ModelAdapter::DBIC
                           CatalystX::CRUD::View::Excel
                           CatalystX::CRUD::YUI
                           CatalystX::Component::Traits
                           CatalystX::ComponentsFromConfig
                           CatalystX::ConsumesJMS
                           CatalystX::Controller::Auth
                           CatalystX::Controller::ExtJS::REST::SimpleExcel
                           CatalystX::Controller::Verifier
                           CatalystX::Crudite
                           CatalystX::Debug::RequestHeaders
                           CatalystX::Debug::ResponseHeaders
                           CatalystX::DebugFilter
                           CatalystX::Declare
                           CatalystX::Dispatcher::AsGraph
                           CatalystX::Example::YUIUploader
                           CatalystX::ExtJS
                           CatalystX::ExtJS::Direct
                           CatalystX::ExtJS::REST
                           CatalystX::FacebookURI
                           CatalystX::Features
                           CatalystX::FeedbackMessages
                           CatalystX::I18N
                           CatalystX::Imports
                           CatalystX::Imports
                           CatalystX::InjectComponent
                           CatalystX::LeakChecker
                           CatalystX::ListFramework
                           CatalystX::Menu::Suckerfish
                           CatalystX::Menu::Tree
                           CatalystX::Menu::mcDropdown
                           CatalystX::MooseComponent
                           CatalystX::OAuth2
                           CatalystX::OAuth2::Provider
                           CatalystX::PSGIApp
                           CatalystX::PathContext
                           CatalystX::Plugin::Blurb
                           CatalystX::Plugin::Engine::FastCGI::Lighttpd
                           CatalystX::Profile
                           CatalystX::REPL
                           CatalystX::RequestRole::StrictParams
                           CatalystX::Resource
                           CatalystX::Restarter::GTK
                           CatalystX::RoleApplicator
                           CatalystX::RoseIntegrator
                           CatalystX::Routes
                           CatalystX::Routes
                           CatalystX::Script::FCGI::Engine
                           CatalystX::Script::Server::Starman
                           CatalystX::SimpleAPI
                           CatalystX::SimpleLogin
                           CatalystX::Starter
                           CatalystX::Syntax::Action
                           CatalystX::Test::MockContext
                           CatalystX::Test::Most
                           CatalystX::Test::Recorder
                           CatalystX::TraitFor::Dispatcher::ExactMatch
                           CatalystX::UriForStatic
                           CatalystX::VCS::Lookup
                           CatalystX::VirtualComponents
                           CatalystX::Widget::Paginator

                           Test::WWW::Mechanize
                           Test::WWW::Mechanize::Catalyst

                           HTML::FormFu
                           HTML::FormFu::Model::DBIC
                           
                           HTML::FormHandler
                           HTML::FormHandler::Model::DBIC
                           HTML::FormHandler::Render::Hash
                           )],
        },

        dancer => {
            filter => [qw(Dancer)],
            modules => [qw(Dancer::Template::Alloy
                           Dancer::Template::Haml
                           Dancer::Template::HtmlTemplate
                           Dancer::Template::MicroTemplate
                           Dancer::Template::MojoTemplate
                           Dancer::Template::TemplateFlute
                           Dancer::Template::TemplateSandbox
                           Dancer::Template::Tenjin
                           Dancer::Template::Tiny
                           Dancer::Template::Xslate
                           Dancer::Logger::ColorConsole
                           Dancer::Logger::Log4perl
                           Dancer::Logger::LogHandler
                           Dancer::Logger::Pipe
                           Dancer::Logger::PSGI
                           Dancer::Logger::Syslog
                           Dancer::Serializer::UUEncode
                           Dancer::Session::CHI
                           Dancer::Session::Cookie
                           Dancer::Session::KiokuDB
                           Dancer::Session::Memcached
                           Dancer::Session::MongoDB
                           Dancer::Session::PSGI
                           Dancer::Session::Storable
                           Dancer::Plugin::Async
                           Dancer::Plugin::Auth::Htpasswd
                           Dancer::Plugin::Auth::RBAC
                           Dancer::Plugin::Auth::Twitter
                           Dancer::Plugin::Bcrypt
                           Dancer::Plugin::Browser
                           Dancer::Plugin::Cache::CHI
                           Dancer::Plugin::Captcha::SecurityImage
                           Dancer::Plugin::Database
                           Dancer::Plugin::DBIC
                           Dancer::Plugin::DebugDump
                           Dancer::Plugin::DebugToolbar
                           Dancer::Plugin::DirectoryView
                           Dancer::Plugin::Dispatcher
                           Dancer::Plugin::ElasticSearch
                           Dancer::Plugin::Email
                           Dancer::Plugin::EncodeID
                           Dancer::Plugin::EscapeHTML
                           Dancer::Plugin::Facebook
                           Dancer::Plugin::Fake::Response
                           Dancer::Plugin::FlashMessage
                           Dancer::Plugin::FlashNote
                           Dancer::Plugin::FormattedOutput
                           Dancer::Plugin::FormValidator
                           Dancer::Plugin::Hosts
                           Dancer::Plugin::LibraryThing
                           Dancer::Plugin::Memcached
                           Dancer::Plugin::MemcachedFast
                           Dancer::Plugin::MobileDevice
                           Dancer::Plugin::Mongo
                           Dancer::Plugin::Mongoose
                           Dancer::Plugin::MPD
                           Dancer::Plugin::Nitesi
                           Dancer::Plugin::NYTProf
                           Dancer::Plugin::ORMesque
                           Dancer::Plugin::Params::Normalization
                           Dancer::Plugin::Passphrase
                           Dancer::Plugin::Preprocess::Sass
                           Dancer::Plugin::Progress
                           Dancer::Plugin::ProxyPath
                           Dancer::Plugin::Redis
                           Dancer::Plugin::REST
                           Dancer::Plugin::SimpleCRUD
                           Dancer::Plugin::SiteMap
                           Dancer::Plugin::SMS
                           Dancer::Plugin::Stomp
                           Dancer::Plugin::Thumbnail
                           Dancer::Plugin::ValidateTiny
                           Dancer::Plugin::ValidationClass
                           Dancer::Plugin::WebSocket
                           Dancer::Plugin::XML::RSS
                           Dancer::Middleware::Rebase
                           Dancer::Debug
            )]
        },

        dbic => {
            filter => [qw(DBIx::Class DBIx::SchemaChecksum SQL Test::DBIx)],
            modules => [qw(DBIx::Class
                           DBIx::Class::Candy
                           DBIx::Class::Cursor::Cached
                           DBIx::Class::DeploymentHandler
                           DBIx::Class::DynamicDefault
                           DBIx::Class::Fixtures
                           DBIx::Class::Helpers
                           DBIx::Class::InflateColumn::Serializer::CompressJSON
                           DBIx::Class::IntrospectableM2M
                           DBIx::Class::LookupColumn
                           DBIx::Class::Manual::SQLHackers
                           DBIx::Class::MaterializedPath
                           DBIx::Class::Migration
                           DBIx::Class::PassphraseColumn
                           DBIx::Class::ResultSet::HashRef
                           DBIx::Class::ResultSet::RecursiveUpdate
                           DBIx::Class::Schema::Loader
                           DBIx::Class::Schema::PopulateMore
                           DBIx::Class::TimeStamp
                           DBIx::Class::Tree
                           DBIx::Class::UnicornLogger
                           DBIx::Class::UUIDColumns
                           DBIx::SchemaChecksum
                           SQL::Abstract
                           SQL::Abstract::More
                           SQL::Translator

                           Test::DBIx::Class)]
        },

        mojo => {
            filter => [qw(Mojo Mojolicious)],
            modules => [qw(Mojolicious)],
        },

        moose => {
            filter => [qw(Moose MooseX Class::MOP)],
            modules => [qw(Moose
                           Moose::Autobox
                           MooseX::Aliases
                           MooseX::App::Cmd
                           MooseX::Attribute::ENV
                           MooseX::AttributeHelpers
                           MooseX::ClassAttribute
                           MooseX::Clone
                           MooseX::ConfigFromFile
                           MooseX::Daemonize
                           MooseX::Declare
                           MooseX::Emulate::Class::Accessor::Fast
                           MooseX::Getopt
                           MooseX::GlobRef
                           MooseX::Has::Options
                           MooseX::InsideOut
                           MooseX::Iterator
                           MooseX::LazyLogDispatch
                           MooseX::LazyRequire
                           MooseX::Log::Log4perl
                           MooseX::LogDispatch
                           MooseX::MarkAsMethods
                           MooseX::Method::Signatures
                           MooseX::MethodAttributes
                           MooseX::NonMoose
                           MooseX::Object::Pluggable
                           MooseX::OneArgNew
                           MooseX::POE
                           MooseX::Param
                           MooseX::Params::Validate
                           MooseX::Role::Cmd
                           MooseX::Role::Parameterized
                           MooseX::Role::TraitConstructor
                           MooseX::Role::WithOverloading
                           MooseX::SemiAffordanceAccessor
                           MooseX::SetOnce
                           MooseX::SimpleConfig
                           MooseX::Singleton
                           MooseX::Storage
                           MooseX::StrictConstructor
                           MooseX::Traits
                           MooseX::Traits::Pluggable
                           MooseX::Types
                           MooseX::Types::Common
                           MooseX::Types::DateTime
                           MooseX::Types::DateTime::ButMaintained
                           MooseX::Types::DateTime::MoreCoercions
                           MooseX::Types::DateTimeX
                           MooseX::Types::DBIx::Class
                           MooseX::Types::Email
                           MooseX::Types::LoadableClass
                           MooseX::Types::Parameterizable
                           MooseX::Types::Path::Class
                           MooseX::Types::Path::Class::MoreCoercions
                           MooseX::Types::Perl
                           MooseX::Types::Set::Object
                           MooseX::Types::Stringlike
                           MooseX::Types::Structured
                           MooseX::Types::XMLSchema
                           MooseX::Workers
                           )]
        },

        plack => {
            filter => [qw(Plack PSGI
                          Starman Starlet Server::Starter
                          Test::WWW::Mechanize::PSGI)],
            modules => [qw(PSGI
                           Plack
                           Plack::Middleware::ForceEnv
                           Plack::Middleware::ReverseProxy
                           Plack::Middleware::ServerStatus::Lite
                           Plack::Test::ExternalServer
                           Test::WWW::Mechanize::PSGI
                           Starman
                           Starlet
                           Server::Starter
            )]
        },
        
        nureg => {
            filter => [qw(NUREG)],
            modules => [qw(
                NUREG::AdobeApp
                NUREG::App
                NUREG::App::DBMigrate
                NUREG::AppLister
                NUREG::Automation
                NUREG::Catalyst::Base
                NUREG::CheckMount
                NUREG::Documentation
                NUREG::Encryption
                NUREG::ExcelExport
                NUREG::ExifTool
                NUREG::FileStorage
                NUREG::JobStorage
                NUREG::RemoteFileSystem
                NUREG::Selenium
                NUREG::SendMail
                NUREG::SendMeasure
                NUREG::Thumbnail
                NUREG::Types
                NUREG::WatchFolder
            )]
        },
    }
}

__PACKAGE__->meta->make_immutable;
1;
