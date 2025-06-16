{
  inputs.nixpkgs.url = "https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      packages.${system} = {
        msvc-wine = pkgs.callPackage ./msvc-wine.nix { };
        msvc-sdk = pkgs.callPackage ./. { msvc-wine = self.packages.${system}.msvc-wine; };
      };
    };
}
