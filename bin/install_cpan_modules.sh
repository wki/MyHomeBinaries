#!/bin/bash
#
# install a well-known set of modules I often need
# path to `cpanm` is not fully quoted to get the current binary
#   especially when using perlbrew
#

# DBD::Pg might need      $ENV{POSTGRES_HOME} = /opt/local/lib/postgresql9x
# XML::LibXML might need  $ENV{XMLPREFIX} = /opt/local

# curl -L http://smartcd.org/install | bash

echo    Bundle::CPAN CPAN::Mini Carton \
        Modern::Perl \
        Imager Imager::File::GIF Imager::File::JPEG Imager::File::PNG \
        Class::Trigger \
        DBD::Pg DateTime::Format::Pg \
        DBIx::Class DBIx::Class::Schema::Loader DBIx::Class::Candy DBIx::Class::Helpers \
        DBIx::Class::DeploymentHandler DBIx::Class::Migration \
        Moose MooseX::Types MooseX::NonMoose \
        MooseX::Getopt MooseX::SimpleConfig \
        MooseX::Types::Path::Class MooseX::Types::Stringlike \
        MooseX::Types::Path::Class::MoreCoercions \
        Moo Role::Tiny \
        Catalyst::Runtime Catalyst::Devel \
        Catalyst::Plugin::ConfigLoader \
        Catalyst::Plugin::Unicode Catalyst::Plugin::I18N \
        Catalyst::Plugin::Authentication Catalyst::Plugin::Authorization::Roles \
        Catalyst::Authentication::Credential::HTTP Catalyst::Plugin::Authentication::Credential::HTTP \
        Catalyst::Plugin::Session \
        Catalyst::Plugin::Static::Simple \
        Catalyst::Plugin::StatusMessage \
        Catalyst::View::ByCode Catalyst::View::Email Catalyst::View::JSON \
        Catalyst::Model::DBIC::Schema Catalyst::Model::Adaptor \
        Catalyst::Controller::Combine Catalyst::Controller::Imager Catalyst::View::ByCode \
        Catalyst::Controller::REST \
        HTML::FormFu HTML::FormFu::Model::DBIC Catalyst::Controller::HTML::FormFu \
        Dancer \
        Web::Simple HTTP::Tiny IO::Socket::SSL\
        Template::Simple \
        Mojolicious \
        Plack \
        Dist::Zilla Dist::Zilla::Plugin::VersionFromModule Dist::Zilla::Plugin::Inject \
        Dist::Zilla::Plugin::Git::Check \
        Test::More Test::Most Test::Exception Test::DBIx::Class \
        XML::LibXML \
        App::pod2pdf \
        IPC::System::Simple IPC::Run3 \
        Hash::Merge \
        Try::Tiny \
        App::Ack \
    | cpanm --mirror ~/minicpan --mirror-only $*

# install plenv if wanted
# git clone git://github.com/tokuhirom/plenv.git ~/.plenv
