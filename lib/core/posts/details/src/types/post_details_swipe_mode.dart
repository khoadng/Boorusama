enum PostDetailsSwipeMode {
  horizontal,
  vertical,
  webtoon;

  factory PostDetailsSwipeMode.parse(dynamic value) => switch (value) {
    'horizontal' || '0' || 0 => horizontal,
    'vertical' || '1' || 1 => vertical,
    'webtoon' || '2' || 2 => webtoon,
    _ => defaultValue,
  };

  static const PostDetailsSwipeMode defaultValue = horizontal;

  bool get isWebtoon => this == webtoon;

  dynamic toData() => index;
}
