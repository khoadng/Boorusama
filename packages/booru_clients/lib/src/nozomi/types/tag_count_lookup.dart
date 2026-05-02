class NozomiTagCountLookup {
  const NozomiTagCountLookup({
    required this.counts,
    required this.missing,
  });

  final Map<String, int> counts;
  final Set<String> missing;
}
