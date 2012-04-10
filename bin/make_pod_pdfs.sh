#!/bin/bash

echo "--- Catalyst ---"
rm -f ~/Desktop/catalyst.pdf
convert_pod2pdf.pl -v -p Catalyst -p CatalystX -p HTML::FormFu -f ~/Desktop/catalyst.pdf

echo "--- Moose ---"
rm -f ~/Desktop/moose.pdf
convert_pod2pdf.pl -v -p Moose -p MooseX -p Class::MOP -f ~/Desktop/moose.pdf

echo "--- Dbix::Class ---"
rm -f ~/Desktop/dbix_class.pdf
convert_pod2pdf.pl -v -p DBIx::Class -p SQL::Abstract -p SQL::Translator -f ~/Desktop/dbix_class.pdf

echo "--- Plack ---"
rm -f ~/Desktop/plack.pdf
convert_pod2pdf.pl -v -p Plack -p PSGI -f ~/Desktop/plack.pdf

echo "--- Mojo* ---"
rm -f ~/Desktop/mojo.pdf
convert_pod2pdf.pl -v -p Mojo -p Mojolicious -f ~/Desktop/mojo.pdf
