#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/lib";
use WK::App::InstallModuleCollections;

WK::App::InstallModuleCollections->new_with_options->run;
