abstract class PostStatus {
  bool matches(String status);
}

class StringPostStatus with LowercaseMatchesStatusMixin implements PostStatus {
  const StringPostStatus._(this.value);

  static StringPostStatus? tryParse(dynamic value) => switch (value) {
    final String s => StringPostStatus._(s),
    _ => null,
  };

  @override
  final String value;
}

mixin LowercaseMatchesStatusMixin implements PostStatus {
  String get value;

  @override
  bool matches(String status) => value.toLowerCase() == status.toLowerCase();
}
