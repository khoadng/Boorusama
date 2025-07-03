// Package imports:
import 'package:booru_clients/philomena.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/tags/autocompletes/types.dart';

const _kSlugReplacement = [
  ['-colon-', ':'],
  ['-dash-', '-'],
  ['-fwslash-', '/'],
  ['-bwslash-', r'\'],
  ['-dot-', '.'],
  ['-plus-', '+'],
];

AutocompleteData parsePhilomenaTagToAutocompleteData(TagDto e) {
  // e is expected to be a tag object with fields: name, slug, aliasedTag, category, images
  return AutocompleteData(
    label: e.name ?? '???',
    value: e.name?.replaceAll(' ', '_') ??
        e.slug.toOption().fold(
              () => '???',
              (slug) => _kSlugReplacement.fold(
                slug,
                (s, repl) => s.replaceAll(repl[1], repl[0]),
              ),
            ),
    antecedent: e.aliasedTag,
    category: e.category ?? '',
    postCount: e.images,
  );
}
