{ symlinkJoin, runCommandNoCC, lib, poetry2nix, python37 }:
let

  interpreter = (poetry2nix.mkPoetryPackages {
      projectDir = ./.;
      inherit overrides;
      python = python37;
    }).python;
  # Make a python derivation pluginable
  #
  # This adds a `withPlugins` function that works much like `withPackages`
  # except it only links binaries from the explicit derivation /share
  # from any plugins
  toPluginAble = {
    drv
    , finalDrv
    , final
  }: drv.overridePythonAttrs(old: {
    passthru = old.passthru // {
      withPlugins = pluginFn: mkPluginDrv {
        plugins = [ finalDrv ] ++ pluginFn final;
        inherit finalDrv;
        inherit interpreter;
      };
    };
  });

  # Wrap the buildEnv derivation in an outer derivation that omits interpreters & other binaries

  mkPluginDrv = {
    finalDrv
    , interpreter
    , plugins
  }: let

    # The complete buildEnv drv
    buildEnvDrv = interpreter.buildEnv.override {
      extraLibs = plugins;
    };

    # Create a separate environment aggregating the share directory
    # This is done because we only want /share for the actual plugins
    # and not for e.g. the python interpreter and other dependencies.
    manEnv = symlinkJoin {
      name = "${finalDrv.pname}-with-plugins-share-${finalDrv.version}";
      preferLocalBuild = true;
      allowSubstitutes = false;
      paths = plugins;
      postBuild = ''
        if test -e $out/share; then
          mv $out out
          mv out/share $out
        else
          rm -r $out
          mkdir $out
        fi
      '';
    };

  in runCommandNoCC "${finalDrv.pname}-with-plugins-${finalDrv.version}" {
    inherit (finalDrv) passthru meta;
  } ''
    mkdir -p $out/bin

    for bindir in ${lib.concatStringsSep " " (map (d: "${lib.getBin d}/bin") plugins)}; do
      for bin in $bindir/*; do
        ln -s ${buildEnvDrv}/bin/$(basename $bin) $out/bin/
      done
    done

    ln -s ${manEnv} $out/share
  '';
  overrides = poetry2nix.overrides.withDefaults (final: prev: {
    # Make nixops pluggable
    nixops = toPluginAble {
      # Attach meta to nixops
      drv = prev.nixops.overridePythonAttrs (old: {
        format = "pyproject";
        buildInputs = old.buildInputs ++ [ final.poetry ];
        meta = old.meta // {
          homepage = https://github.com/NixOS/nixops;
          description = "NixOS cloud provisioning and deployment tool";
          maintainers = with lib.maintainers; [ aminechikhaoui eelco rob domenkozar ];
          platforms = lib.platforms.unix;
          license = lib.licenses.lgpl3;
        };
      });
      finalDrv = final.nixops;
      inherit final;
    };

    importlib-metadata = prev.importlib-metadata.overrideAttrs (old: {
      postPatch = old.postPatch or "" + ''
        sed -i '/\[metadata\]/aversion = ${old.version}' setup.cfg
      '';
    });

  });
in
  {
    inherit interpreter overrides;
  }
