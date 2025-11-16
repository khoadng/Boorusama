abstract class PostFilterQuery<T> {
  bool shouldInclude(T item);
}

class NonePostFilterQuery<T> extends PostFilterQuery<T> {
  NonePostFilterQuery();

  @override
  bool shouldInclude(T item) => true;
}

final postFilterQueryNone = NonePostFilterQuery();

class CustomPostFilterQuery<T> extends PostFilterQuery<T> {
  CustomPostFilterQuery({
    required this.includeWhen,
  });

  final bool Function(T item) includeWhen;

  @override
  bool shouldInclude(T item) => includeWhen(item);
}
