{
  inputs.nixpkgs.url = "https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
    }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (import rust-overlay) ];
      };
    in
    {
      packages.${system} = {
        default = self.packages.${system}.clang-cl;
        msvc-wine = pkgs.callPackage ./sdk/msvc-wine.nix { };
        msvc-sdk = pkgs.callPackage ./sdk/msvc-sdk.nix {
          msvc-wine = self.packages.${system}.msvc-wine;
        };
        clang-cl = pkgs.callPackage ./clang {
          msvc-sdk = self.packages.${system}.msvc-sdk;
          msvc-wine = self.packages.${system}.msvc-wine;
        };
        rustc = pkgs.callPackage ./rustc {
          msvc-sdk = self.packages.${system}.msvc-sdk;
          msvc-wine = self.packages.${system}.msvc-wine;
          clang-cl = self.packages.${system}.clang-cl;
          rustc = pkgs.rust-bin.stable.latest.minimal.override {
            targets = [ "x86_64-pc-windows-msvc" ];
          };
        };
      };

      checks.${system} = {
        inherit (self.packages.${system}) clang-cl rustc;
      };

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
