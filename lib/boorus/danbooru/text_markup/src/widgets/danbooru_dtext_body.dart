// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/dtext/widgets.dart';
import '../../../../../core/text_markup/providers.dart';
import '../../../../../core/text_markup/types.dart';

class DanbooruDTextBody extends ConsumerWidget {
  const DanbooruDTextBody({
    required this.data,
    required this.config,
    super.key,
    this.style,
    this.onLinkTap,
    this.selectable = true,
  });

  final String data;
  final BooruConfigAuth config;
  final Map<String, Style>? style;
  final OnTap? onLinkTap;
  final bool selectable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emojiNames = extractTextEmojiShortcodes(data);
    final mediaRefs = extractTextMediaEmbedRefs(data);
    final textMarkupCache = ref.watch(textMarkupCacheProvider(config));

    return DTextBody(
      data: data,
      booruUrl: config.url,
      emojiMap: {
        for (final name in emojiNames) name: ?textMarkupCache.resolved[name],
      },
      mediaEmbedMap: {
        for (final ref in mediaRefs) ref: ?textMarkupCache.mediaEmbeds[ref],
      },
      imageConfig: config,
      style: style,
      onLinkTap: onLinkTap,
      selectable: selectable,
    );
  }
}
