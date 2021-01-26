# Nixops 2.0 with plugins

## Plugins

```
+-----------------------+
|   Installed Plugins   |
+-----------------------+
|          aws          |
|    encrypted_links    |
|          gcp          |
| nixos_modules_contrib |
+-----------------------+
```

## Nixpkgs & poetry2nix

nixpkgs and poetry2nix are currently being submitted in the Hydra jobset

For the local build, they should be added as extra nix store path via the `-I` flag

## Spawn dev-shell

- Activate poetry

```
nix-shell -I channel:nixos-20.09 -p poetry
```

- Re-lock poetry if needed

```
poetry lock
```

- Install the dependencies

```
poetry install
```

- Enter the shell

```
poetry shell
```

## Add a plugin

Install poetry in some way.

Add your plugin to both `pyproject.toml` and `nixops-pluggable.nix`.

Run `poetry lock`. If you made any errors editing `pyproject.toml` it should
tell you.

Run `nix-build`.


## Remote build

Hydra jobset

## About

Cloned from [nixopsenv from adisbladis](https://github.com/adisbladis/nixopsenv/).

