{
  nixpkgs ? ( builtins.fetchGit { url = "https://github.com/NixOS/nixpkgs.git"; rev = "nixos-20.09" } ).outPath
, poetry2nix ? ( builtins.fetchGit { url = "https://github.com/nix-community/poetry2nix.git"; rev = "master" } ).outPath
}:
let
  defaultPkgs = import nixpkgs {
    overlays = [ (import (poetry2nix + "/overlay.nix")) ];
  };
in
  { pkgs ? defaultPkgs,
  }:
(import ./nixops-pluggable.nix { inherit pkgs; }).devShell
