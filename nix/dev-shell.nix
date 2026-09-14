{
  pkgs,
  flutter,
  expectedFlutterVersion,
}:

let
  workspaceDart = pkgs.writeShellScriptBin "boorusama-dart" ''
    if [[ "$PWD" != */packages/boorusama_cli && "''${1:-}" == run ]]; then
      package_config_root="$PWD"
      while [[ "$package_config_root" != / && ! -f "$package_config_root/.dart_tool/package_config.json" ]]; do
        package_config_root="$(${pkgs.coreutils}/bin/dirname "$package_config_root")"
      done
      package_config="$package_config_root/.dart_tool/package_config.json"

      if [[ "''${2:-}" == *.dart ]]; then
        shift
        exec ${flutter}/bin/dart \
          --packages="$package_config" "$@"
      fi

      target="''${2:-}"
      package="''${target%%:*}"
      executable="''${target#*:}"
      if [[ "$executable" == "$target" ]]; then
        executable="$package"
      fi
      package_root="$(${pkgs.jq}/bin/jq -r --arg name "$package" \
        '.packages[] | select(.name == $name) | .rootUri' "$package_config")"
      if [[ "$package_root" == file://* ]]; then
        package_root="''${package_root#file://}"
      else
        package_root="$(${pkgs.coreutils}/bin/realpath -m \
          "$package_config_root/.dart_tool/$package_root")"
      fi
      shift 2
      exec ${flutter}/bin/dart --packages="$package_config" \
        "$package_root/bin/$executable.dart" "$@"
    fi
    exec ${flutter}/bin/dart "$@"
  '';
  boorusamaCli = pkgs.writeShellScriptBin "boorusama" ''
    root="''${BOORUSAMA_ROOT:-}"
    if [[ -z "$root" ]]; then
      root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    fi

    cli_dir="$root/packages/boorusama_cli"
    if [[ ! -f "$cli_dir/pubspec.yaml" ]]; then
      echo "boorusama: run this command from the Boorusama repository" >&2
      exit 1
    fi

    cd "$cli_dir"
    exec env BOORUSAMA_ROOT="$root" ${flutter}/bin/dart \
      run boorusama_cli:boorusama "$@"
  '';
in
pkgs.mkShell {
  packages = with pkgs; [
    flutter
    git
    boorusamaCli

    clang
    cmake
    ninja
    meson
    nasm
    pkg-config

    gtk3
    libepoxy
    libGL
    libass
    libplacebo
    libunwind
    shaderc
    vulkan-loader
    lcms2
    libdovi
    ffmpeg
    mpv
    xz

    rustup

    rsync
    file
    jq
    yq
    nix-prefetch-git
    gnutar
    zip
  ];

  BOORUSAMA_USE_FVM = "false";
  BOORUSAMA_DART = "${workspaceDart}/bin/boorusama-dart";
  DART_SUPPRESS_ANALYTICS = "true";
  FLUTTER_SUPPRESS_ANALYTICS = "true";

  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (
    with pkgs;
    [
      gtk3
      libepoxy
      libGL
      libass
      libplacebo
      libunwind
      shaderc
      vulkan-loader
      lcms2
      libdovi
      ffmpeg
      mpv
      xz
    ]
  );

  shellHook = ''
    export BOORUSAMA_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    export PUB_CACHE="$BOORUSAMA_ROOT/.dart_tool/nix-pub-cache"
    export CARGO_HOME="$BOORUSAMA_ROOT/.dart_tool/nix-cargo"
    export RUSTUP_HOME="$BOORUSAMA_ROOT/.dart_tool/nix-rustup"
    export XDG_CACHE_HOME="$BOORUSAMA_ROOT/.dart_tool/nix-cache"
    mkdir -p "$PUB_CACHE" "$CARGO_HOME" "$RUSTUP_HOME" "$XDG_CACHE_HOME"

    if [ ${pkgs.lib.escapeShellArg flutter.version} != ${pkgs.lib.escapeShellArg expectedFlutterVersion} ]; then
      echo "warning: using Flutter ${flutter.version} for a source build; the official release toolchain is ${expectedFlutterVersion}" >&2
      echo "warning: patch differences are supported for source builds; official FVM builds remain exact" >&2
    fi
  '';
}
