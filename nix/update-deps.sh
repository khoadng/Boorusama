#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for tool in yq jq nix-prefetch-git nix; do
  command -v "$tool" >/dev/null 2>&1 || {
    printf 'update-deps: %s is required; run this script inside nix develop\n' "$tool" >&2
    exit 1
  }
done

root_json="$(mktemp "${TMPDIR:-/tmp}/boorusama-pubspec-lock.XXXXXX")"
cli_json="$(mktemp "${TMPDIR:-/tmp}/boorusama-cli-pubspec-lock.XXXXXX")"
hash_lines="$(mktemp "${TMPDIR:-/tmp}/boorusama-git-hashes.XXXXXX")"
hash_json="$(mktemp "${TMPDIR:-/tmp}/boorusama-git-hashes-json.XXXXXX")"
cargo_hash_json="$(mktemp "${TMPDIR:-/tmp}/boorusama-cargo-hashes-json.XXXXXX")"
trap 'rm -f "$root_json" "$cli_json" "$hash_lines" "$hash_json" "$cargo_hash_json"' EXIT

yq . "$ROOT/pubspec.lock" >"$root_json"
yq . "$ROOT/packages/boorusama_cli/pubspec.lock" >"$cli_json"

while IFS=$'\t' read -r name url revision; do
  printf 'Prefetching %s\n' "$name" >&2
  result="$(nix-prefetch-git --quiet --url "$url" --rev "$revision")"
  hash="$(jq -r '.hash // .sha256' <<<"$result")"
  if [[ "$hash" != sha256-* ]]; then
    hash="$(nix hash convert --hash-algo sha256 --to sri "$hash")"
  fi
  printf '%s\t%s\n' "$name" "$hash" >>"$hash_lines"
done < <(
  jq -r '
    .packages
    | to_entries[]
    | select(.value.source == "git")
    | [.key, .value.description.url, .value.description["resolved-ref"]]
    | @tsv
  ' "$root_json"
)

jq -Rn '
  [inputs | split("\t") | {(.[0]): .[1]}]
  | add // {}
' <"$hash_lines" >"$hash_json"

libavif_url="$(jq -r '.packages.libavif.description.url' "$root_json")"
libavif_revision="$(jq -r '.packages.libavif.description["resolved-ref"]' "$root_json")"
libavif_path="$(jq -r '.packages.libavif.description.path' "$root_json")"
libavif_version="$(jq -r '.packages.libavif.version' "$root_json")"
libavif_source_hash="$(jq -r '.libavif' "$hash_json")"

for value in "$libavif_url" "$libavif_revision" "$libavif_path" "$libavif_version" "$libavif_source_hash"; do
  if [[ -z "$value" || "$value" == null ]]; then
    printf 'update-deps: incomplete libavif lock metadata\n' >&2
    exit 1
  fi
done

root_nix="$(jq -Rn --arg value "$ROOT" '$value')"
url_nix="$(jq -Rn --arg value "$libavif_url" '$value')"
revision_nix="$(jq -Rn --arg value "$libavif_revision" '$value')"
path_nix="$(jq -Rn --arg value "$libavif_path" '$value')"
version_nix="$(jq -Rn --arg value "$libavif_version" '$value')"
source_hash_nix="$(jq -Rn --arg value "$libavif_source_hash" '$value')"
cargo_expression="$(printf '%s\n' \
  'let' \
  "  flake = builtins.getFlake $root_nix;" \
  '  pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; };' \
  '  source = pkgs.fetchgit {' \
  "    url = $url_nix;" \
  "    rev = $revision_nix;" \
  "    hash = $source_hash_nix;" \
  '  };' \
  'in pkgs.rustPlatform.fetchCargoVendor {' \
  '  pname = "libavif-native";' \
  "  version = $version_nix;" \
  '  src = source;' \
  "  sourceRoot = source.name + \"/\" + $path_nix + \"/native\";" \
  '  hash = pkgs.lib.fakeHash;' \
  '}')"

printf 'Prefetching libavif Cargo dependencies\n' >&2
if cargo_output="$(nix build --impure --no-link --expr "$cargo_expression" 2>&1)"; then
  printf 'update-deps: Cargo hash probe unexpectedly succeeded\n' >&2
  exit 1
fi
cargo_hash="$(sed -n 's/^[[:space:]]*got:[[:space:]]*//p' <<<"$cargo_output" | tail -n 1)"
if [[ "$cargo_hash" != sha256-* ]]; then
  printf '%s\n' "$cargo_output" >&2
  printf 'update-deps: could not determine libavif Cargo hash\n' >&2
  exit 1
fi
jq -n --arg hash "$cargo_hash" '{libavif: $hash}' >"$cargo_hash_json"

mv "$root_json" "$ROOT/nix/pubspec.lock.json"
mv "$cli_json" "$ROOT/nix/cli-pubspec.lock.json"
mv "$hash_json" "$ROOT/nix/git-hashes.json"
mv "$cargo_hash_json" "$ROOT/nix/cargo-hashes.json"

printf 'Updated Nix dependency metadata.\n'
