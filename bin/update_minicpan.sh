#!/bin/bash
#
# refresh all updated modules from a given CPAN mirror
#
minicpan_dir=$HOME/minicpan
cpan_mirror=http://cpan.noris.de/

minicpan -l $minicpan_dir -r $cpan_mirror
