# i18n_cli

Project CLI for maintaining Boorusama translation JSON files.

## Usage

From the repository root:

```sh
dart run i18n_cli:booru_i18n get generic.done
dart run i18n_cli:booru_i18n search "Done" --locale en-US
dart run i18n_cli:booru_i18n tree post.detail --depth 2
dart run i18n_cli:booru_i18n missing --locale vi-VN
dart run i18n_cli:booru_i18n validate
```

Add a new key:

```sh
dart run i18n_cli:booru_i18n add post.detail.copy_link \
  --translation en-US="Copy link" \
  --translation vi-VN="Sao chep lien ket"
```

Add several related base-locale keys under one parent:

```sh
dart run i18n_cli:booru_i18n add-batch post.action \
  copy="Copy" \
  media="Media" \
  links="Links" \
  copy_post_link="Copy post link" \
  --dry-run \
  --diff
```

`add-batch` reports proposed keys that already exist and exact same-value
matches elsewhere. It only writes keys that are new.

Preview a write without touching files:

```sh
dart run i18n_cli:booru_i18n add post.detail.copy_link \
  --translation en-US="Copy link" \
  --dry-run
```

Preview the exact patch:

```sh
dart run i18n_cli:booru_i18n add post.detail.copy_link \
  --translation en-US="Copy link" \
  --dry-run \
  --diff
```

Use JSON output for agents and automation:

```sh
dart run i18n_cli:booru_i18n add post.detail.copy_link \
  --translation en-US="Copy link" \
  --dry-run \
  --json
```

Use a manifest when an agent wants to add keys and replace source text in one
reviewable operation:

```sh
dart run i18n_cli:booru_i18n manifest-template
dart run i18n_cli:booru_i18n normalize-manifest /tmp/i18n_patch.json
dart run i18n_cli:booru_i18n apply /tmp/i18n_patch.json --dry-run --diff
```

Manifest shape:

```json
{
  "locale": "en-US",
  "add": {
    "post.action.copy": "Copy"
  },
  "replace": [
    {
      "file": "lib/example.dart",
      "from": "'Copy'.hc",
      "to": "context.t.post.action.copy",
      "count": 1
    }
  ]
}
```

Source replacements are literal and strict. The command fails if the exact
`from` text appears a different number of times than `count`. If `count` is
omitted, `apply` infers it when the text appears at least once.

The manifest parser is tolerant of cheap-model output. It accepts fenced JSON,
leading/trailing prose, trailing commas, `keys` arrays, `parent` plus relative
keys, and replacement aliases like `path`/`old`/`new`. The normalized form can
be inspected with `normalize-manifest`. Normalization warnings are summarized
so dry-run output stays compact.

Inspect the translation tree without printing values:

```sh
dart run i18n_cli:booru_i18n tree --depth 2
dart run i18n_cli:booru_i18n tree post.detail --depth 1
```

## Write Safety

Normal write commands preserve existing JSON structure as much as possible.
They do not reformat whole locale files. The explicit `format` command is the
only command that intentionally rewrites complete JSON files.

Use `--dry-run` before broad changes and `--json` when another tool needs to
parse the result. Use `--diff` with `--dry-run` when an agent or maintainer
needs to inspect the exact patch before writing.

## Commands

- `get <key>` reads one key.
- `add <key>` adds a missing key to the locales passed with `--translation`.
- `add-batch <parent-key> key=value [...]` adds several child keys and reports
  exact existing keys plus same-value matches.
- `apply <manifest.json>` applies manifest additions and exact source
  replacements.
- `set <key>` updates one locale value.
- `remove <key>` removes a key from one locale or all locales.
- `rename <old-key> <new-key>` renames a key in one locale or all locales.
- `missing` lists keys that exist in the base locale but are missing elsewhere.
- `search <query>` searches keys and values.
- `tree [key]` prints the key tree without values.
- `validate` checks JSON, value shape, and placeholder consistency.
- `format` explicitly formats one locale or all locales.
- `manifest-template` prints a template for cheap-model manifest generation.
- `normalize-manifest <manifest.json>` prints the strict manifest JSON that
  `apply` will use.
