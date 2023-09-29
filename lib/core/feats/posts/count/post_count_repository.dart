abstract class PostCountRepository {
  Future<int?> count(List<String> tags);
}

class PostCountRepositoryBuilder implements PostCountRepository {
  PostCountRepositoryBuilder({
    required this.countTags,
    this.extraTags,
  });

  final List<String>? extraTags;
  final Future<int?> Function(List<String> tags) countTags;

  @override
  Future<int?> count(List<String> tags) => count(
        [...tags, ...extraTags ?? []],
      );
}

class EmptyPostCountRepository implements PostCountRepository {
  const EmptyPostCountRepository();

  @override
  Future<int?> count(List<String> tags) => Future<int?>.value(null);
}
