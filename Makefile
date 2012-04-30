all:	
	rsync -vcr bin/* ~/bin/
	rsync -vc dot_files/profile ~/.profile
	[ -f ~/bin/cpanm ]    || curl -L -s http://cpanmin.us > ~/bin/cpanm
	[ -f ~/bin/perlbrew ] || curl -k -L -s https://raw.github.com/gugod/App-perlbrew/master/perlbrew > ~/bin/perlbrew
	chmod a+x ~/bin/*
