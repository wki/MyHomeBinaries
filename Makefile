all:	
	rsync -vc bin/* ~/bin/
	rsync -vc dot_files/profile ~/.profile
