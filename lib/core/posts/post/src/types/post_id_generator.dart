class PostIdGenerator {
  final Set<int> _generatedIds = {};

  int generateId() {
    final id = _generatedIds.length + 1;
    _generatedIds.add(id);
    return id;
  }
}
