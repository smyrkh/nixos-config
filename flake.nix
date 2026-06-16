{
	description = "A very basic flake";

	inputs = {
		# nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
		nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-25.11";
	};

	outputs = { self, nixpkgs }: {

		# nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
		# 	system = "aarch64-linux";
		# 	modules = [
		# 		./configuration.nix
		# 	];
		# };

		nixosConfigurations.nixos-aarch64 = nixpkgs.lib.nixosSystem {
			system = "aarch64-linux";
			modules = [
				./configuration.nix
			];
		};
		nixosConfigurations.nixos-x86_64 = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				./configuration.nix
			];
		};
		nixosConfigurations.nixos = self.nixosConfigurations.nixos-aarch64;
	};
}
