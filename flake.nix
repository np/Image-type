{
  description = "image-type";

  nixConfig = {
    extra-substituters = "https://horizon.cachix.org";
    extra-trusted-public-keys = "horizon.cachix.org-1:MeEEDRhRZTgv/FFGCv3479/dmJDfJ82G6kfUDxMSAw0=";
  };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    horizon-advance.url = "git+https://gitlab.horizon-haskell.net/package-sets/horizon-advance";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
      perSystem = { pkgs, system, ... }:
        let
          myOverlay = final: prev: {
            image-type = final.callCabal2nix "image-type" ./. { };

          };
          legacyPackages = inputs.horizon-advance.legacyPackages.${system}.extend myOverlay;
        in
        rec {

          devShells.default = legacyPackages.shellFor {
            packages = p: [ p.image-type ];
            buildInputs = [
              legacyPackages.cabal-install
            ];
          };

          inherit legacyPackages;

          packages = rec {
            inherit (legacyPackages)
              image-type;
            default = packages.image-type;
          };

        };
    };
}
