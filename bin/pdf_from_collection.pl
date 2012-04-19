#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/lib";
use WK::App::PdfFromCollection;

WK::App::PdfFromCollection->new_with_options->run;
