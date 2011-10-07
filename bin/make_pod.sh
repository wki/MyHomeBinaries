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
pod_dir=`dirname $(perldoc -l Catalyst)`
pdf_dir=$HOME/Desktop/CPAN

mkdir -p $pdf_dir

cd $pod_dir
for file in `find Mojo* SQL Moose* Catalyst* DBIx HTML/Form* PSGI* Plack* Web* XML* -type f`
do 
    dir=`dirname $file`
    pdf=${file/.*/.pdf}
    
    # echo "file=$file, dir=$dir, pdf=$pdf"
    
    if [[ ! -f "$pdf_dir/$pdf" || "$pdf_dir/$pdf" -ot "$file" ]] ; then
        pod_nr_text_lines=`pod2text $file | wc -l`
        
        if (( pod_nr_text_lines == 0 )); then
            rm -f $pdf_dir/$pdf
        else
            echo "generating $file"
            mkdir -p $pdf_dir/$dir
            pod2pdf $file > $pdf_dir/$pdf
        fi
    else
        echo "nothing to do for $file"
    fi
done

