// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/engine/providers.dart';
import '../../configs/config/types.dart';
import 'types/text_emoji.dart';
import 'types/text_media_embed.dart';

final textMarkupCacheProvider =
    NotifierProvider.family<
      TextMarkupCacheNotifier,
      TextMarkupCache,
      BooruConfigAuth
    >(TextMarkupCacheNotifier.new);

class TextMarkupCacheNotifier
    extends FamilyNotifier<TextMarkupCache, BooruConfigAuth> {
  @override
  TextMarkupCache build(BooruConfigAuth arg) {
    return const TextMarkupCache();
  }

  Future<Map<String, TextEmoji>> resolveEmojiShortcodes(
    Set<String> names,
  ) async {
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
        state = state.withMissingEmojis(unresolved);
      } else {
        final Map<String, TextEmoji> resolved;
        try {
          resolved = await repository.resolveEmojiShortcodes(unresolved);
        } catch (_) {
          return _resolvedEmojiSubset(normalizedNames);
        }

        state = state
            .withResolvedEmojis(resolved)
            .withMissingEmojis(
              unresolved.where((name) => !resolved.containsKey(name)),
            );
      }
    }

    return _resolvedEmojiSubset(normalizedNames);
  }

  Future<Map<TextMediaEmbedRef, TextMediaEmbed>> resolveMediaEmbeds(
    Set<TextMediaEmbedRef> refs,
  ) async {
    final unresolved = refs
        .where(
          (ref) =>
              !state.mediaEmbeds.containsKey(ref) &&
              !state.missingMediaEmbeds.contains(ref),
        )
        .toSet();

    if (unresolved.isNotEmpty) {
      final repository = ref.read(booruRepoProvider(arg))?.textMarkup(arg);
      if (repository == null) {
        state = state.withMissingMediaEmbeds(unresolved);
      } else {
        final Map<TextMediaEmbedRef, TextMediaEmbed> resolved;
        try {
          resolved = await repository.resolveMediaEmbeds(unresolved);
        } catch (_) {
          return _resolvedMediaEmbedSubset(refs);
        }

        state = state
            .withResolvedMediaEmbeds(resolved)
            .withMissingMediaEmbeds(
              unresolved.where((ref) => !resolved.containsKey(ref)),
            );
      }
    }

    return _resolvedMediaEmbedSubset(refs);
  }

  Future<void> resolveBodies(Iterable<String> bodies) async {
    final bodyList = bodies.toList();
    final names = {
      for (final body in bodyList) ...extractTextEmojiShortcodes(body),
    };
    final mediaRefs = {
      for (final body in bodyList) ...extractTextMediaEmbedRefs(body),
    };

    if (names.isNotEmpty) {
      await resolveEmojiShortcodes(names);
    }

    if (mediaRefs.isNotEmpty) {
      await resolveMediaEmbeds(mediaRefs);
    }
  }

  Map<String, TextEmoji> _resolvedEmojiSubset(Set<String> names) =>
      Map.unmodifiable({
        for (final name in names) name: ?state.resolved[name],
      });

  Map<TextMediaEmbedRef, TextMediaEmbed> _resolvedMediaEmbedSubset(
    Set<TextMediaEmbedRef> refs,
  ) => Map.unmodifiable({
    for (final ref in refs) ref: ?state.mediaEmbeds[ref],
  });
}

class TextMarkupCache {
  const TextMarkupCache({
    this.resolved = const {},
    this.missing = const {},
    this.mediaEmbeds = const {},
    this.missingMediaEmbeds = const {},
  });

  final Map<String, TextEmoji> resolved;
  final Set<String> missing;
  final Map<TextMediaEmbedRef, TextMediaEmbed> mediaEmbeds;
  final Set<TextMediaEmbedRef> missingMediaEmbeds;

  TextMarkupCache withResolvedEmojis(Map<String, TextEmoji> values) {
    if (values.isEmpty) return this;

    return TextMarkupCache(
      resolved: Map.unmodifiable({
        ...resolved,
        ...values,
      }),
      missing: missing,
      mediaEmbeds: mediaEmbeds,
      missingMediaEmbeds: missingMediaEmbeds,
    );
  }

  TextMarkupCache withMissingEmojis(Iterable<String> names) {
    final namesSet = names.toSet();
    if (namesSet.isEmpty) return this;

    return TextMarkupCache(
      resolved: resolved,
      missing: Set.unmodifiable({
        ...missing,
        ...namesSet,
      }),
      mediaEmbeds: mediaEmbeds,
      missingMediaEmbeds: missingMediaEmbeds,
    );
  }

  TextMarkupCache withResolvedMediaEmbeds(
    Map<TextMediaEmbedRef, TextMediaEmbed> values,
  ) {
    if (values.isEmpty) return this;

    return TextMarkupCache(
      resolved: resolved,
      missing: missing,
      mediaEmbeds: Map.unmodifiable({
        ...mediaEmbeds,
        ...values,
      }),
      missingMediaEmbeds: missingMediaEmbeds,
    );
  }

  TextMarkupCache withMissingMediaEmbeds(Iterable<TextMediaEmbedRef> refs) {
    final refsSet = refs.toSet();
    if (refsSet.isEmpty) return this;

    return TextMarkupCache(
      resolved: resolved,
      missing: missing,
      mediaEmbeds: mediaEmbeds,
      missingMediaEmbeds: Set.unmodifiable({
        ...missingMediaEmbeds,
        ...refsSet,
      }),
    );
  }
}
