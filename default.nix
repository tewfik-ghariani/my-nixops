let
  defaultPkgs = import <nixpkgs> {
    overlays = [ (import (<poetry2nix> + "/overlay.nix")) ];
  };
in
  { pkgs ? defaultPkgs,
  }:
{
  nixops = (import ./nixops-pluggable.nix { inherit pkgs; }).nixops;
}
