This is my setup on new hosts:

	~ $ mkdir dev
	~ $ cd dev
	~/dev $ git clone https://github.com/smanjo/home.git
	Cloning into 'home'...
	remote: Enumerating objects: 95, done.
	remote: Counting objects: 100% (95/95), done.
	remote: Compressing objects: 100% (68/68), done.
	remote: Total 95 (delta 46), reused 71 (delta 26), pack-reused 0
	Unpacking objects: 100% (95/95), done.
	~/dev $ cd home/
	~/dev/home $ ./install.sh
	checking installed setup (18 packages)...
	  MISSING   : curl
	  MISSING   : htop
	  MISSING   : iftop
	  MISSING   : wget
	missing 4 package(s), run this command to install:
	
	sudo apt install curl htop iftop wget
	
	checking home setup (9 files)...
	  INSTALLED: /home/user/.bash_profile
	  INSTALLED: /home/user/.profile [ backup created: /home/user/.profile.bak ]
	  INSTALLED: /home/user/.bashrc [ backup created: /home/user/.bashrc.bak ]
	  INSTALLED: /home/user/.bash_logout [ backup created: /home/user/.bash_logout.bak ]
	  INSTALLED: /home/user/.inputrc
	  INSTALLED: /home/user/.curlrc [ not found: curl ]
	  INSTALLED: /home/user/.digrc
	  INSTALLED: /home/user/.emacs [ backup created: /home/user/.emacs.bak ]
	  INSTALLED: /home/user/.wgetrc [ not found: wget ]
	home setup complete: 9 newly installed, 0 skipped (already setup).
