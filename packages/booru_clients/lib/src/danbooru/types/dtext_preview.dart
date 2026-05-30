sealed class DanbooruDTextEmojiValue {
  const DanbooruDTextEmojiValue();
}

class DanbooruDTextEmojiText extends DanbooruDTextEmojiValue {
  const DanbooruDTextEmojiText(this.text);

  final String text;
}

class DanbooruDTextEmojiImage extends DanbooruDTextEmojiValue {
  const DanbooruDTextEmojiImage(
    this.url, {
    this.width,
    this.height,
  });

  final String url;
  final int? width;
  final int? height;
}
