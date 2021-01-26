{
  pkgs
}:
let
  overridesXX = import ./overrides.nix {
    inherit (pkgs) lib runCommandNoCC symlinkJoin;
    inherit poetry2nix;
    inherit (pkgs) python37;
  };

  overrides = overridesXX.overrides;
  interpreter = overridesXX.interpreter;
  inherit (pkgs) poetry2nix;
in
  rec {
    nixopsPluggable = interpreter.pkgs.nixops;

    nixops = nixopsPluggable.withPlugins (ps: [
      ps.nixops-aws
      ps.nixops-gcp
      ps.nixops-encrypted-links
    ]);

    devShell = pkgs.mkShell {
      buildInputs = [
        (poetry2nix.mkPoetryEnv {
          projectDir = ./.;
          inherit overrides;
          python = pkgs.python37;
        })
        pkgs.poetry
      ];
    };
  }
