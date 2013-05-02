#!/bin/bash
#
# patch /opt/local/etc/macports/variants.conf and add:
# +no_x11
# -x11
# +quartz


# install some commonly used ports

sudo port install jpeg
sudo port install giflib@4.2.1+no_x11
sudo port install libpng
sudo port install tiff
sudo port install libxml2

# LaTeX
sudo port install texlive-latex
sudo port install texlive-latex-extra
sudo port install texlive-latex-recommended
sudo port install texlive-lang-german

sudo port install gnupg2
