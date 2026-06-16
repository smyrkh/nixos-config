{
config,
lib,
pkgs,
...
}:
{
	imports = [
		./hardware-configuration.nix
	];

	# This option defines the first version of NixOS you have installed on this particular machine,
	# and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
	#
	# Most users should NEVER change this value after the initial install, for any reason,
	# even if you've upgraded your system to a new NixOS release.
	#
	# This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
	# so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
	# to actually do that.
	#
	# This value being lower than the current NixOS release does NOT mean your system is
	# out of date, out of support, or vulnerable.
	#
	# Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
	# and migrated your data accordingly.
	#
	# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
	system.stateVersion = "24.11"; # Did you read the comment?

	boot = {
		loader = {
			# Use the systemd-boot EFI boot loader.
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
		};
		kernel = {
			# default is 33. "Couldn't write '33' to 'vm/mmap_rnd_bits': Invalid argument"
			sysctl."vm.mmap_rnd_bits" = 18;
		};
	};

	nix = {
		settings = {
			experimental-features = [
				"nix-command"
				"flakes"
			];
		};
		# enable gc
		gc = {
			automatic = true;
			dates = "weekly";
		};
	};

	nixpkgs.config = {
		allowUnfree = true;
		permittedInsecurePackages = [
			"docker-28.5.2"
		];
	};

	# install programs
	environment.systemPackages = with pkgs; [
		# -- base packages --

		# manual
		man-pages
		man-pages-posix
		# dotfiles
		stow
		# neovim clipboard
		xclip
		# container
		docker
		# aws
		awscli2
		# decompress zip
		unzip
		# download file
		wget
		# interactive filter
    fzf

		# -- development packages --

		# common
		gnumake
		cmake
		# nix
		nixfmt-rfc-style
		# c
		gcc
		# java
		jdk
		# rust
		rustup
		# go
		go
		# python
		(python3.withPackages (pypkgs: with pypkgs; [
			# lsp
			python-lsp-server
			pluggy
			python-lsp-jsonrpc
			docstring-to-markdown
			jedi
			parso

			# analysis
			pwntools
			pycrypto
		]))
		# javascript
		volta
		# lua
		lua-language-server
    # parser
    tree-sitter

		# -- improved packages --

		# ls
		eza
		# cat
		bat
		# grep
		ripgrep
		# find
		fd
		# ps
		procs
		# top
		htop
		# df
		duf
		# du
		dust
		# mysql
		mycli
    # zsh prompt
    starship

		# -- analysis packages

		# shows type of files
		file
		# checksec, cyclic, pwntools-gdb etc...
		pwntools
		# edit binary
		tinyxxd
		# edit exif
		exiftool
		# emulator
		qemu
		# operate image
		imagemagick
		# decompose file
		binwalk
		# trace
		ltrace
		# compress executable file
		upx
		# operate bit of image
		# commented out: unable to extract plane 0
		# also following error occured
		# (java:1341): Gtk-WARNING **: 18:00:48.792: Could not load a pixbuf from /org/gtk/libgtk/theme/Adwaita/assets/bullet-symbolic.svg.
		# This may indicate that pixbuf loaders or the mime database could not be found.
		# stegsolve
		# cryptography
		openssl
		# port scanner
		nmap
		# WebAssembly
		wabt

		# -- ai packages

		gemini-cli

		# -- X

		xorg.xeyes

		firefox
		xdg-utils
	];

	environment.variables = {
		BROWSER = "firefox";
	};

	# enable programs
	programs = {
		nix-ld = {
			enable = true;
		};
		zsh = {
			enable = true;
		};
		neovim = {
			enable = true;
			defaultEditor = true;
			viAlias = true;
			vimAlias = true;
		};
		git = {
			enable = true;
		};
	};

	# enable services
	services = {
		openssh = {
			enable = true;
			settings = {
				X11Forwarding = true;
				X11DisplayOffset = 10;
				X11UseLocalhost = false;
			};
		};

		# utm config
		qemuGuest.enable = true;
		spice-vdagentd.enable = true;
		spice-webdavd.enable = true;

		# mDNS
		avahi = {
			enable = true;
			nssmdns4 = true;
			publish = {
				enable = true;
				addresses = true;
				workstation = true;
			};
		};
	};

	documentation.dev.enable = true;
	virtualisation.docker.enable = true;

	# add user
	users = {
		# commented out: enable root login without initialHashedPassword for root
		# mutableUsers = false;
		users."smyrkh" = {
			isNormalUser = true;
      uid = 1001;
			extraGroups = [
				"wheel"
				"docker"
				"networkmanager"
			];
			shell = pkgs.zsh;
			# initialHashedPassword = "";
			openssh.authorizedKeys.keys = [
				"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJy3mLo8TJYL9i1Og79m14zl9YiOdHeR6F+tcSOtFkKo"
			];
		};
	};
	security.sudo.extraRules = [
		{
			users = [ "smyrkh" ];
			commands = [
				{
					command = "ALL";
					options = [ "NOPASSWD" ];
				}
			];
		}
	];

	# network config
	networking = {
		hostName = "nixos";

		# dynamic
		useDHCP = true;

		# static
		# useDHCP = false;
		# interfaces.enp0s1.ipv4.addresses = [
		# 	{
		# 		address = "192.168.3.111";
		# 		# address = "10.244.132.111";
		# 		prefixLength = 24;
		# 	}
		# ];
		# defaultGateway = "192.168.3.1";
		# # defaultGateway = "10.244.132.1";
		# nameservers = [
		# 	"1.1.1.1"
		# 	"8.8.8.8"
		# ];

		# NetworkManager
		# networkmanager.enable = true;
	};

	# utm config
	fileSystems."/mnt/share" = {
		fsType = "virtiofs";
		device = "share";
		options = [
			"rw"
			"nofail"
		];
	};
	# x86_64 execution config on arm
	virtualisation.rosetta.enable = true;
}
