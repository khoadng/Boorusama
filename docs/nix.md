# Building with Nix

Boorusama supports `x86_64-linux` and `aarch64-linux`. Install Nix with flakes
enabled before using the commands below. A graphical desktop is not required
to build the application.

On NixOS, flakes can be enabled with:

```nix
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

## Build and run

Build the FOSS application package:

```bash
mkdir -p build/nix
nix build .#boorusama --out-link build/nix/boorusama
```

The executable is available at:

```text
build/nix/boorusama/bin/boorusama
```

`build/nix/boorusama` is a symlink to the immutable package in the Nix store.
On a Linux graphical session, build and launch it directly with:

```bash
nix run .#boorusama
```

## Development

Enter the development shell and initialize the workspace:

```bash
nix develop
./init.sh
```

The shell provides Flutter, Dart, Rust, Linux build dependencies, and the
repository's `boorusama` CLI. For example:

```bash
boorusama doctor linux --foss
boorusama build linux --foss --debug
```

Nix source builds accept the same Flutter major/minor version as `.fvmrc` and
warn when only the patch version differs. Official builds using FVM require the
exact version from `.fvmrc`.

## Updating Nix dependency metadata

After changing either Pub lockfile, regenerate the committed Nix dependency
metadata, including Git source hashes and the libavif Cargo vendor hash:

```bash
nix develop --command nix/update-deps.sh
```
