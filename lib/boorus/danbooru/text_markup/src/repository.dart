// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../../../../core/text_markup/types.dart';

class DanbooruTextMarkupRepository implements TextMarkupRepository {
  DanbooruTextMarkupRepository({
    required this.client,
  });

  final DanbooruClient client;
  final _cache = <String, TextEmoji>{};
  final _missing = <String>{};

  @override
  Future<Map<String, TextEmoji>> resolveEmojiShortcodes(
    Set<String> names,
  ) async {
    final normalizedNames = names
        .map((name) => name.toLowerCase())
        .where(isValidTextEmojiShortcode)
        .toSet();

    final unresolved = normalizedNames
        .where((name) => !_cache.containsKey(name) && !_missing.contains(name))
        .toSet();

    if (unresolved.isNotEmpty) {
      final resolved = await _resolveMissingEmojiShortcodes(unresolved);
      _cache.addAll(resolved);
      _missing.addAll(unresolved.where((name) => !resolved.containsKey(name)));
    }

    return Map.unmodifiable({
      for (final name in normalizedNames) name: ?_cache[name],
    });
  }

  Future<Map<String, TextEmoji>> _resolveMissingEmojiShortcodes(
    Set<String> names,
  ) async {
    final values = await client.getDTextEmojiValues(names);

    return Map.unmodifiable({
      for (final entry in values.entries) entry.key: _toTextEmoji(entry.value),
    });
  }

  @override
  Future<Map<TextMediaEmbedRef, TextMediaEmbed>> resolveMediaEmbeds(
    Set<TextMediaEmbedRef> refs,
  ) async {
    if (refs.isEmpty) return const {};

    final postIds = {
      for (final ref in refs)
        if (ref.type == TextMediaEmbedType.post) ref.id,
    };
    final assetIds = {
      for (final ref in refs)
        if (ref.type == TextMediaEmbedType.asset) ref.id,
    };

    final posts = await client.getPostsByIds(postIds);
    final assets = await client.getMediaAssetsByIds(assetIds);
    final resolved = <TextMediaEmbedRef, TextMediaEmbed>{};

    for (final post in posts) {
      final id = post.id;
      if (id == null) continue;

      final ref = TextMediaEmbedRef(type: TextMediaEmbedType.post, id: id);
      final pageUrl = _pageUrlFor(ref);
      resolved[ref] = _toTextMediaEmbed(
        ref: ref,
        pageUrl: pageUrl,
        asset: post.mediaAsset,
      );
    }

    for (final asset in assets) {
      final id = asset.id;
      if (id == null) continue;

      final ref = TextMediaEmbedRef(type: TextMediaEmbedType.asset, id: id);
      final pageUrl = _pageUrlFor(ref);
      resolved[ref] = _toTextMediaEmbed(
        ref: ref,
        pageUrl: pageUrl,
        asset: asset,
      );
    }

    for (final ref in refs) {
      resolved.putIfAbsent(
        ref,
        () => TextMediaUnavailableEmbed(
          ref: ref,
          pageUrl: _pageUrlFor(ref),
        ),
      );
    }

    return Map.unmodifiable(resolved);
  }

  TextMediaEmbed _toTextMediaEmbed({
    required TextMediaEmbedRef ref,
    required String pageUrl,
    required MediaAssetDto? asset,
  }) {
    if (asset == null ||
        (asset.status != null && asset.status != 'active') ||
        !_isImage(asset)) {
      return TextMediaUnavailableEmbed(ref: ref, pageUrl: pageUrl);
    }

    final variant = _preferredImageVariant(asset);
    final url = variant?.url;
    if (url == null || url.isEmpty) {
      return TextMediaUnavailableEmbed(ref: ref, pageUrl: pageUrl);
    }

    return TextMediaImageEmbed(
      ref: ref,
      pageUrl: pageUrl,
      imageUrl: url,
      width: variant?.width ?? asset.imageWidth ?? 1,
      height: variant?.height ?? asset.imageHeight ?? 1,
    );
  }

  VariantDto? _preferredImageVariant(MediaAssetDto asset) {
    final variants = asset.variants ?? const <VariantDto>[];

    for (final type in const [
      '720x720',
      'sample',
      'original',
      '360x360',
      '180x180',
    ]) {
      for (final variant in variants) {
        if (variant.type == type && _isImageUrl(variant.url)) {
          return variant;
        }
      }
    }

    return null;
  }

  String _pageUrlFor(TextMediaEmbedRef ref) {
    final path = switch (ref.type) {
      TextMediaEmbedType.post => '/posts/${ref.id}',
      TextMediaEmbedType.asset => '/media_assets/${ref.id}',
    };

    return Uri.parse(client.dio.options.baseUrl).resolve(path).toString();
  }
}

TextEmoji _toTextEmoji(DanbooruDTextEmojiValue value) {
  return switch (value) {
    DanbooruDTextEmojiText(:final text) => TextEmojiText(text),
    DanbooruDTextEmojiImage(:final url, :final width, :final height) =>
      TextEmojiImage(url, width: width, height: height),
  };
}

bool _isImage(MediaAssetDto asset) {
  return switch (asset.fileExt?.toLowerCase()) {
    'jpg' || 'jpeg' || 'png' || 'gif' || 'webp' || 'avif' => true,
    _ => false,
  };
}

bool _isImageUrl(String? value) {
  final path = Uri.tryParse(value ?? '')?.path.toLowerCase() ?? '';

  return path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.png') ||
      path.endsWith('.gif') ||
      path.endsWith('.webp') ||
      path.endsWith('.avif');
}
