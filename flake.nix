{
  description = "Boorusama Linux development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      source = nixpkgs.lib.cleanSource ./.;
      fvmConfig = builtins.fromJSON (builtins.readFile ./.fvmrc);
      expectedFlutterVersion = fvmConfig.flutter;
      flutterSeries = version:
        nixpkgs.lib.concatStringsSep "." (
          nixpkgs.lib.take 2 (nixpkgs.lib.splitString "." version)
        );
      expectedFlutterSeries = flutterSeries expectedFlutterVersion;
      supportsFlutter = flutter: flutterSeries flutter.version == expectedFlutterSeries;
      unsupportedFlutterMessage = flutter:
        "Boorusama source builds require Flutter ${expectedFlutterSeries}.x; nixpkgs provides ${flutter.version}";
    in
    {
      overlays.default = final: _prev: {
        boorusama = self.packages.${final.system}.boorusama;
      };

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          flutter = pkgs.flutterPackages.v3_47;
          boorusama = assert nixpkgs.lib.assertMsg (supportsFlutter flutter) (unsupportedFlutterMessage flutter); import ./nix/package.nix {
            inherit pkgs flutter;
            src = source;
            gitCommit = self.rev or self.dirtyRev or "unknown";
            gitBranch = "nix";
          };
        in
        {
          inherit boorusama;
          default = boorusama;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          flutter = pkgs.flutterPackages.v3_47;
        in
        {
          default = assert nixpkgs.lib.assertMsg (supportsFlutter flutter) (unsupportedFlutterMessage flutter); import ./nix/dev-shell.nix {
            inherit pkgs flutter expectedFlutterVersion;
          };
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          flutter = pkgs.flutterPackages.v3_47;
        in
        {
          boorusama = self.packages.${system}.boorusama;
          flutter-version = pkgs.runCommand "boorusama-flutter-version" { } ''
            expected=${pkgs.lib.escapeShellArg expectedFlutterVersion}
            actual=${pkgs.lib.escapeShellArg flutter.version}
            expected_series=${pkgs.lib.escapeShellArg expectedFlutterSeries}
            actual_series=${pkgs.lib.escapeShellArg (flutterSeries flutter.version)}
            if [ "$actual_series" != "$expected_series" ]; then
              echo "Unsupported Flutter version: source builds require $expected_series.x, pinned nixpkgs provides $actual" >&2
              exit 1
            fi
            if [ "$actual" != "$expected" ]; then
              echo "warning: using Flutter $actual for a source build; the official release toolchain is $expected" >&2
            fi
            touch "$out"
          '';
        }
      );
    };
}
