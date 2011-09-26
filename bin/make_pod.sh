#!/bin/bash
#
# Generate PDF files from .pod/.pm files
#
# my lazy script for generating all (at least for me) relevant pod documents
# converted to PDF in a tree that is parallel to the CPAN installation
# not perfect but works for me.
#
# pod2pdf is required, please install from CPAN first!
#   http://search.cpan.org/~jonallen/pod2pdf-0.42
#

#
# some variables to allow customization
#
pod_dir=/Library/Perl/5.10.0
pdf_dir=$HOME/Desktop/CPAN

mkdir -p $pdf_dir

cd $pod_dir
for i in `find Mojo* SQL Moose* Catalyst* DBIx HTML/Form* PSGI* Plack* -type f`
do 
    j=`dirname $i`
    
    if [[ ! -f "$pdf_dir/$i.pdf" || "$pdf_dir/$i.pdf" -ot "$i" ]] ; then
        echo "generating $i"
        mkdir -p $pdf_dir/$j
        pod2pdf $i > $pdf_dir/$i.pdf
    else
        echo "nothing to do for $i"
    fi
done

