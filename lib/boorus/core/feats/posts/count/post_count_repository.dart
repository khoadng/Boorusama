abstract class PostCountRepository {
  Future<int?> count(List<String> tags);
}

class EmptyPostCountRepository implements PostCountRepository {
  const EmptyPostCountRepository();

  @override
  Future<int?> count(List<String> tags) => Future<int?>.value(null);
}
