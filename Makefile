all:	
	rsync -vcr bin/* ~/bin/
	rsync -vc dot_files/profile ~/.profile
	chmod a+x ~/bin/*
	# cd misc_apps; dzil install
	exec $$SHELL -l
