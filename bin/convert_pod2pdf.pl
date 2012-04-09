#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/lib";
use WK::App::ConvertPod2Pdf;

WK::App::ConvertPod2Pdf->new_with_options->run;
