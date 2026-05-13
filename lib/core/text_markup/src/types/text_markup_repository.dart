import 'text_emoji.dart';

abstract interface class TextMarkupRepository {
  Future<Map<String, TextEmoji>> resolveEmojiShortcodes(Set<String> names);
}
