all:	
	rsync -vc bin/* ~/bin/
	rsync -vc dot_files/profile ~/.profile
	curl -L -s http://cpanmin.us > ~/bin/cpanm
	curl -k -L -s https://raw.github.com/gugod/App-perlbrew/master/perlbrew > ~/bin/perlbrew
	chmod a+x ~/bin/*
