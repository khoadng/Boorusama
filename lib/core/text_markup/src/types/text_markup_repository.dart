import 'text_emoji.dart';
import 'text_media_embed.dart';

abstract interface class TextMarkupRepository {
  Future<Map<String, TextEmoji>> resolveEmojiShortcodes(Set<String> names);

  Future<Map<TextMediaEmbedRef, TextMediaEmbed>> resolveMediaEmbeds(
    Set<TextMediaEmbedRef> refs,
  );
}
