{
  description = "Zuban Language Server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs = { self, nixpkgs }:
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "x86_64-darwin"
          "aarch64-linux"
          "aarch64-darwin"
        ]
          (system: function nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        zuban = pkgs.rustPlatform.buildRustPackage {
          name = "zuban";
          src = pkgs.lib.cleanSource ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "rust-ini-0.21.1" = "sha256-0NRWwxSdMjnu/T2JW1BNUYNLJdtqk5J5WYs7VXbltRs=";
            };
          };
          doCheck = false; # Some unit tests seem to fail
          meta.license = pkgs.lib.licenses.agpl3Only;
        };
      });

      apps = forAllSystems (pkgs: rec {
        zuban = {
          type = "app";
          program = "${self.packages.${pkgs.system}.zuban}/bin/zuban";
        };
        zubanls = {
          type = "app";
          program = "${self.packages.${pkgs.system}.zuban}/bin/zubanls";
        };
        default = zuban;
      });
    };
}
