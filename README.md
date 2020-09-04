This is my setup on new hosts:

	~ $ mkdir dev
	~ $ cd dev
	~/dev $ git clone https://github.com/smanjo/home.git
	Cloning into 'home'...
	remote: Enumerating objects: 61, done.
	remote: Counting objects: 100% (61/61), done.
	remote: Compressing objects: 100% (43/43), done.
	remote: Total 61 (delta 30), reused 49 (delta 18), pack-reused 0
	Unpacking objects: 100% (61/61), done.
	~/dev $ cd home
	~/dev/home $ ./install.sh
	starting install of 8 files...
	installing /home/user/.bash_profile
	...creating backup of existing file: /home/user/.profile -> /home/user/.profile.bak
	installing /home/user/.profile
	...creating backup of existing file: /home/user/.bashrc -> /home/user/.bashrc.bak
	installing /home/user/.bashrc
	...creating backup of existing file: /home/user/.bash_logout -> /home/user/.bash_logout.bak
	installing /home/user/.bash_logout
	installing /home/user/.curlrc  [ used by: /usr/bin/curl ]
	installing /home/user/.digrc  [ used by: /usr/bin/dig ]
	...creating backup of existing file: /home/user/.emacs -> /home/user/.emacs.bak
	installing /home/user/.emacs  [ used by: /usr/bin/emacs ]
	installing /home/user/.wgetrc  [ not found: wget ]
	done.
