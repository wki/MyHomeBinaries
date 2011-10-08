#!/bin/bash
#
# install a well-known set of modules I often need
# path to `cpan` is not fully quoted to get the current binary 
#   especially when using perlbrew
#
for m in Bundle::CPAN \
         Imager Imager::File::GIF Imager::File::JPEG Imager::File::PNG \
         Class::Trigger \
         DBD::Pg DateTime::Format::Pg \
         DBIx::Class DBIx::Class::Schema::Loader DBIx::Class::Candy DBIx::Class::Helpers \
         Moose MooseX::Types MooseX::NonMoose \
         Catalyst::Runtime Catalyst::Devel \
         Catalyst::Plugin::ConfigLoader \
         Catalyst::Plugin::Unicode Catalyst::Plugin::I18N \
         Catalyst::Plugin::Authentication Catalyst::Plugin::Authorization::Roles \
         Catalyst::Authentication::Credential::HTTP Catalyst::Plugin::Authentication::Credential::HTTP \
         Catalyst::Plugin::Session \
         Catalyst::Plugin::Static::Simple \
         Catalyst::View::ByCode Catalyst::View::Email Catalyst::View::JSON \
         Catalyst::Model::DBIC::Schema Catalyst::Model::Adaptor \
         Catalyst::Controller::Combine Catalyst::Controller::Imager Catalyst::View::ByCode \
         HTML::FormFu HTML::FormFu::Model::DBIC Catalyst::Controller::HTML::FormFu \
         Dancer \
         Web::Simple \
         Mojolicious \
         Plack \
         Dist::Zilla \
         Test::More Test::Most Test::Exception Test::DBIx::Class \
         JONALLEN/pod2pdf-0.42.tar.gz
do
    cpan $m
done
