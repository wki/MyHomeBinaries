all:	
	rsync -vc bin/* ~/bin/
	rsync -vc dot_files/profile ~/.profile
	curl -L -s http://cpanmin.us > ~/bin/cpanm
	chmod a+x ~/bin/*
