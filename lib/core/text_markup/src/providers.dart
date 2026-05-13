// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/engine/providers.dart';
import '../../configs/config/types.dart';
import 'types/text_emoji.dart';

final textEmojiCacheProvider =
    NotifierProvider.family<
      TextEmojiCacheNotifier,
      TextEmojiCache,
      BooruConfigAuth
    >(TextEmojiCacheNotifier.new);

class TextEmojiCacheNotifier
    extends FamilyNotifier<TextEmojiCache, BooruConfigAuth> {
  @override
  TextEmojiCache build(BooruConfigAuth arg) {
    return const TextEmojiCache();
  }

  Future<Map<String, TextEmoji>> resolve(Set<String> names) async {
    final normalizedNames = names
        .map((name) => name.toLowerCase())
        .where(isValidTextEmojiShortcode)
        .toSet();

    final unresolved = normalizedNames
        .where(
          (name) =>
              !state.resolved.containsKey(name) &&
              !state.missing.contains(name),
        )
        .toSet();

    if (unresolved.isNotEmpty) {
      final repository = ref.read(booruRepoProvider(arg))?.textMarkup(arg);
      if (repository == null) {
        state = state.withMissing(unresolved);
      } else {
        final Map<String, TextEmoji> resolved;
        try {
          resolved = await repository.resolveEmojiShortcodes(unresolved);
        } catch (_) {
          return _resolvedSubset(normalizedNames);
        }

        state = state
            .withResolved(resolved)
            .withMissing(
              unresolved.where((name) => !resolved.containsKey(name)),
            );
      }
    }

    return _resolvedSubset(normalizedNames);
  }

  Future<void> resolveBodies(Iterable<String> bodies) async {
    final names = {
      for (final body in bodies) ...extractTextEmojiShortcodes(body),
    };

    if (names.isEmpty) return;

    await resolve(names);
  }

  Map<String, TextEmoji> _resolvedSubset(Set<String> names) =>
      Map.unmodifiable({
        for (final name in names) name: ?state.resolved[name],
      });
}

class TextEmojiCache {
  const TextEmojiCache({
    this.resolved = const {},
    this.missing = const {},
  });

  final Map<String, TextEmoji> resolved;
  final Set<String> missing;

  TextEmojiCache withResolved(Map<String, TextEmoji> values) {
    if (values.isEmpty) return this;

    return TextEmojiCache(
      resolved: Map.unmodifiable({
        ...resolved,
        ...values,
      }),
      missing: missing,
    );
  }

  TextEmojiCache withMissing(Iterable<String> names) {
    final namesSet = names.toSet();
    if (namesSet.isEmpty) return this;

    return TextEmojiCache(
      resolved: resolved,
      missing: Set.unmodifiable({
        ...missing,
        ...namesSet,
      }),
    );
  }
}
