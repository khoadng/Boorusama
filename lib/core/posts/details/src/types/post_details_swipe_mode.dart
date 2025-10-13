enum PostDetailsSwipeMode {
  horizontal,
  vertical;

  factory PostDetailsSwipeMode.parse(dynamic value) => switch (value) {
    'horizontal' || '0' || 0 => horizontal,
    'vertical' || '1' || 1 => vertical,
    _ => defaultValue,
  };

  static const PostDetailsSwipeMode defaultValue = horizontal;

  dynamic toData() => index;
}
