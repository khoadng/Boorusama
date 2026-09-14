{
  pkgs,
  flutter,
  src,
  gitCommit ? "unknown",
  gitBranch ? "unknown",
}:

let
  inherit (pkgs) lib stdenv;

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

  versionLine = lib.findFirst (
    line: lib.hasPrefix "version:" line
  ) (throw "version is missing from pubspec.yaml") (lib.splitString "\n" (builtins.readFile (src + "/pubspec.yaml")));
  version = lib.trim (lib.removePrefix "version:" versionLine);
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  gitHashes = lib.importJSON ./git-hashes.json;
  cargoHashes = lib.importJSON ./cargo-hashes.json;
  libavifDependency = pubspecLock.packages.libavif;
  libavifDescription = libavifDependency.description;

  libavifSource = pkgs.fetchgit {
    url = libavifDescription.url;
    rev = libavifDescription.resolved-ref;
    hash = gitHashes.libavif;
  };
  libavifCargoDeps = pkgs.rustPlatform.fetchCargoVendor {
    pname = "libavif-native";
    version = libavifDependency.version;
    src = libavifSource;
    sourceRoot = "${libavifSource.name}/${libavifDescription.path}/native";
    hash = cargoHashes.libavif;
  };
  cargoConfig = pkgs.writeText "boorusama-cargo-config.toml" ''
    [source.vendored-source-registry-0]
    directory = "${libavifCargoDeps}/source-registry-0"

    [source.crates-io]
    replace-with = "vendored-source-registry-0"
  '';

  cli = (pkgs.buildDartApplication.override { dart = flutter; }) {
    pname = "boorusama-cli";
    inherit version;
    src = src + "/packages/boorusama_cli";
    pubspecLock = lib.importJSON ./cli-pubspec.lock.json;
    dartEntryPoints = {
      "bin/boorusama" = "bin/boorusama.dart";
    };
  };

  mdkSdk = pkgs.fetchurl {
    url =
      if stdenv.hostPlatform.isAarch64 then
        "https://github.com/wang-bin/mdk-sdk/releases/download/v0.38.0/mdk-sdk-linux.tar.xz"
      else
        "https://github.com/wang-bin/mdk-sdk/releases/download/v0.38.0/mdk-sdk-linux-x64.tar.xz";
    hash =
      if stdenv.hostPlatform.isAarch64 then
        "sha256-DOXMAqKtsHvQ0EPSy4i72XZpKC+EhiTqPdENU3dXr/c="
      else
        "sha256-nOKbHCmqLQUeUvUK+KFXirgPbReVWik1UU4cabiiPT4=";
  };

  copyPatchedSource =
    {
      pname,
      version,
      src,
      postPatch ? "",
    }:
    stdenv.mkDerivation {
      inherit pname version src postPatch;
      inherit (src) passthru;
      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        runHook preInstall
        mkdir -p "$out"
        cp -R . "$out"
        runHook postInstall
      '';
    };

  desktopItem = pkgs.makeDesktopItem {
    name = "com.degenk.boorusama";
    desktopName = "Boorusama";
    comment = "Browse and manage images from booru sites";
    exec = "boorusama";
    icon = "com.degenk.boorusama";
    categories = [ "Graphics" ];
    terminal = false;
  };
in
flutter.buildFlutterApplication {
  pname = "boorusama";
  inherit version src;

  inherit pubspecLock;
  inherit gitHashes;

  customSourceBuilders = {
    fvp =
      { version, src, ... }:
      copyPatchedSource {
        pname = "fvp";
        inherit version src;
        postPatch = ''
          sed -i '/file(WRITE.*VERSION_HEADER_FILE/d' cmake/deps.cmake
          mkdir -p linux/mdk-sdk
          tar -xJf ${mdkSdk} -C linux
          test -f linux/mdk-sdk/lib/cmake/FindMDK.cmake
        '';
      };

    native_toolchain_rust =
      { version, src, ... }:
      copyPatchedSource {
        pname = "native-toolchain-rust";
        inherit version src;
        postPatch = ''
          sed -i "/logger.info('Running cargo build');/,/environment: {/ {
            s/processRunner.invokeRustup(/processRunner.invoke('cargo',/
            /^[[:space:]]*'run',[[:space:]]*$/d
            /^[[:space:]]*toolchainChannel,[[:space:]]*$/d
            /^[[:space:]]*'cargo',[[:space:]]*$/d
            /environment: {/a\        'CARGO_HOME': Platform.environment['HOME']! + '/.cargo',
            /environment: {/a\        'CARGO_NET_OFFLINE': 'true',
          }" native_toolchain_rust/lib/src/build_runner.dart
          substituteInPlace native_toolchain_rust/lib/src/build_runner.dart \
            --replace-fail "processRunner.invokeRustup([" "processRunner.invoke('rustc', [" \
            --replace-fail "'show'," "'--version'," \
            --replace-fail "'active-toolchain'," ""
          test "$(grep -c "processRunner.invoke('cargo'," native_toolchain_rust/lib/src/build_runner.dart)" -eq 1
          test "$(grep -c "processRunner.invoke('rustc'," native_toolchain_rust/lib/src/build_runner.dart)" -eq 1
          ! grep -q "invokeRustup" native_toolchain_rust/lib/src/build_runner.dart
          substituteInPlace native_toolchain_rust/lib/src/process_runner.dart \
            --replace-fail "if (result.exitCode != 0) {" \
              "if (result.exitCode != 0) {
        stderr.write(result.stderr);
        stdout.write(result.stdout);"
        '';
      };
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    cli
    copyDesktopItems
    git
    clang
    cmake
    ninja
    meson
    nasm
    pkg-config
    rustc
    cargo
    gnumake
    gnutar
    which
    zip
  ];

  buildInputs = with pkgs; [
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
    libdvdnav
    libdvdread
    libdvdcss
    mujs
    wayland
    libarchive
    libbluray
    lua5_1
    rubberband
    libuchardet
    libxfixes
    libx11
    zimg
    zlib
    alsa-lib
    openal
    pipewire
    libpulseaudio
    libcaca
    libdrm
    libdisplay-info
    mesa
    libgbm
    wayland-protocols
    libxkbcommon
    libxscrnsaver
    libxext
    libxpresent
    libxrandr
    nv-codec-headers-12
    libva
    libvdpau
    lz4
    xz
  ];

  # MDK ships an optional Rockchip hardware-decoder backend. Nixpkgs' own MDK
  # package ignores this library too because rockchip-mpp is not packaged.
  autoPatchelfIgnoreMissingDeps = [ "librockchip_mpp.so.1" ];

  desktopItems = [ desktopItem ];

  # CMake and Meson are needed by Flutter's Linux plugins, but the application
  # has no repository-root configure step. Keep the Dart/Flutter setup hooks so
  # Nix installs the generated, immutable package configuration.
  configurePhase = ''
    runHook preConfigure
    runHook postConfigure
  '';

  BOORUSAMA_USE_FVM = "false";
  BOORUSAMA_DART = "${workspaceDart}/bin/boorusama-dart";
  BOORUSAMA_GIT_COMMIT = gitCommit;
  BOORUSAMA_GIT_BRANCH = gitBranch;
  DART_SUPPRESS_ANALYTICS = "true";
  FLUTTER_SUPPRESS_ANALYTICS = "true";

  buildPhase = ''
    runHook preBuild

    export HOME="$NIX_BUILD_TOP/home"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_CACHE_HOME="$HOME/.cache"
    export CARGO_HOME="$HOME/.cargo"
    mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$CARGO_HOME"
    cp ${cargoConfig} "$CARGO_HOME/config.toml"
    export BOORUSAMA_ROOT="$PWD"
    boorusama build linux \
      --foss \
      --release \
      --offline \
      --ci \
      --output-dir "$NIX_BUILD_TOP/boorusama-artifacts"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    artifact="$(find "$NIX_BUILD_TOP/boorusama-artifacts" -maxdepth 1 -name '*-linux-*.tar.gz' -print -quit)"
    test -n "$artifact"

    # buildFlutterApplication always declares this output on Linux.
    mkdir -p "$debug" "$out/app/boorusama" "$out/bin"
    tar -xzf "$artifact" -C "$out/app/boorusama"
    ln -s "$out/app/boorusama/boorusama" "$out/bin/boorusama"

    install -Dm644 assets/icon/icon-512x512.png \
      "$out/share/icons/hicolor/512x512/apps/com.degenk.boorusama.png"

    runHook postInstall
  '';

  meta = {
    description = "Booru client for desktop and mobile";
    homepage = "https://github.com/khoadng/Boorusama";
    license = lib.licenses.gpl3Only;
    mainProgram = "boorusama";
    platforms = lib.platforms.linux;
  };
}
