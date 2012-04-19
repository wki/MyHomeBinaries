package WK::App::PdfFromCollection;
use Modern::Perl;
use Moose;
use MooseX::Types::Path::Class qw(File Dir);
use JSON;
use File::Temp ();
use Config;
use DateTime;
use WK::App::ConvertPod2Pdf;
use autodie ':all';
use namespace::autoclean;

extends 'WK::App';
with 'MooseX::Getopt';

has directory => (
    traits => ['Getopt'],
    is => 'ro',
    isa => Dir,
    required => 1,
    lazy_build => 1,
    coerce => 1,
    cmd_aliases => 'd',
    documentation => 'directory to build into, defaults to a temp dir',
);

has target_file => (
    traits => ['Getopt'],
    is => 'rw',
    isa => File,
    required => 1,
    lazy_build => 1,
    coerce => 1,
    cmd_flag => 'save_to',
    cmd_aliases => 'f',
    documentation => 'A File to save to ',
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

has cpanm_options => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'ArrayRef[Str]',
    required => 1,
    lazy => 1,
    cmd_aliases => 'o',
    default => sub {
        -d "$ENV{HOME}/minicpan"
            ? ['--mirror', "$ENV{HOME}/minicpan", '--mirror-only']
            : [],
    },
    documentation => 'Typical options for cpanm. Uses a minicpan mirror dir at $HOME/minicpan if present',
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

has pdf_converter => (
    traits => ['NoGetopt'],
    is => 'rw',
    isa => 'WK::App::ConvertPod2Pdf',
    lazy_build => 1,
);

sub run {
    my $self = shift;

    $self->log_debug('Temp Dir:', $self->directory);

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

sub _build_directory {
    my $self = shift;

    File::Temp::tempdir(CLEANUP => 1);
}

sub _build_target_file {
    my $self = shift;
    
    "$ENV{HOME}/Desktop/${\$self->collection}.pdf"
}

sub _build_pdf_converter {
    my $self = shift;

    WK::App::ConvertPod2Pdf->new(
        filter_packages => $self->filter_packages,
        directory       => $self->directory->subdir('lib/perl5'),
        target_file     => $self->target_file,
        verbose         => $self->verbose,
      # debug           => 1,
    );
}

sub install_module {
    my $self = shift;
    my $module = shift;

    $self->log_dryrun("would install $module") and return;
    $self->log("Installing $module");

    # cpanm still generates some output. Currently we just ignore this fact...
    system join ' ',
                $self->cpanm,
                @{$self->cpanm_options},
                '-n',
                '-q',
                '-L' => $self->directory,
                $module,
                ($self->debug ? () : '>/dev/null 2>/dev/null'),
                ;
}

sub collect_installed_modules {
    my $self = shift;

    $self->log_dryrun("would collect module versions") and return;
    $self->log('collecting module versions');

    my $meta_dir = $self->directory->subdir("lib/perl5/$Config{archname}/.meta");
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

    $toc .= "=item $_ (${\$self->installed_modules->{$_}})\n\n" for sort @{$self->modules};

    $toc .= <<POD;

=back

=cut
POD

    my $toc_file = $self->directory->subdir('lib/perl5')->file('toc.pod')->openw;
    print $toc_file $toc;
    $toc_file->close;
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
        or die "Collection '$collection' not found. Available are: " . join(', ', keys %{__info()});
    return $info;
}

sub __info {
    {
        catalyst => {
            filter => [qw(Catalyst CatalystX
                          Test::WWW
                          HTML::FormFu)],
            modules => [qw(Catalyst::Action::REST
                           Catalyst::Action::RenderView
                           Catalyst::Action::RenderView::ErrorHandler
                           Catalyst::ActionRole::DetachOnDie
                           Catalyst::Authentication::Credential::HTTP
                           Catalyst::Component::ACCEPT_CONTEXT
                           Catalyst::Component::InstancePerContext
                           Catalyst::Controller::ActionRole
                           Catalyst::Controller::Combine
                           Catalyst::Controller::HTML::FormFu
                           Catalyst::Controller::FormBuilder
                           Catalyst::Controller::Imager
                           Catalyst::Controller::POD
                           Catalyst::Devel
                           Catalyst::Manual
                           Catalyst::Model::Adaptor
                           Catalyst::Model::DBIC::Schema
                           Catalyst::Model::File
                           Catalyst::Model::REST
                           Catalyst::Model::Redis
                           Catalyst::Plugin::Authentication
                           Catalyst::Plugin::Authentication::Credential::HTTP
                           Catalyst::Plugin::Authorization::Roles
                           Catalyst::Plugin::AutoCRUD
                           Catalyst::Plugin::Cache
                           Catalyst::Plugin::ConfigLoader
                           Catalyst::Plugin::DefaultEnd
                           Catalyst::Plugin::I18N
                           Catalyst::Plugin::Session
                           Catalyst::Plugin::Session::State::Cookie
                           Catalyst::Plugin::Session::Store::File
                           Catalyst::Plugin::Session::Store::DBIC
                           Catalyst::Plugin::Session::Store::FastMmap
                           Catalyst::Plugin::Session::Store::Redis
                           Catalyst::Plugin::Session::Store::Memcached
                           Catalyst::Plugin::Static::Simple
                           Catalyst::Plugin::Unicode
                           Catalyst::Plugin::UploadProgress
                           Catalyst::Plugin::XSendFile
                           Catalyst::Runtime
                           Catalyst::View::ByCode
                           Catalyst::View::Download
                           Catalyst::View::Email
                           Catalyst::View::JSON
                           Catalyst::View::TT
                           CatalystX::Component::Traits
                           CatalystX::REPL

                           Test::WWW::Mechanize
                           Test::WWW::Mechanize::Catalyst

                           HTML::FormFu
                           HTML::FormFu::Model::DBIC)],
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
            filter => [qw(DBIx::Class SQL Test::DBIx)],
            modules => [qw(DBIx::Class
                           DBIx::Class::Candy
                           DBIx::Class::Cursor::Cached
                           DBIx::Class::DeploymentHandler
                           DBIx::Class::DynamicDefault
                           DBIx::Class::Fixtures
                           DBIx::Class::Helpers
                           DBIx::Class::IntrospectableM2M
                           DBIx::Class::Migration
                           DBIx::Class::PassphraseColumn
                           DBIx::Class::ResultSet::HashRef
                           DBIx::Class::ResultSet::RecursiveUpdate
                           DBIx::Class::Schema::Loader
                           DBIx::Class::Schema::PopulateMore
                           DBIx::Class::TimeStamp
                           DBIx::Class::Tree
                           DBIx::Class::UUIDColumns
                           SQL::Abstract
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
                           MooseX::Types::LoadableClass
                           MooseX::Types::Path::Class
                           MooseX::Types::Perl
                           MooseX::Types::Set::Object
                           MooseX::Types::Structured
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
        }
    }
}

__PACKAGE__->meta->make_immutable;
1;
