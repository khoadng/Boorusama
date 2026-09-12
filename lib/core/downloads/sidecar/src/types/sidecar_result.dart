class SidecarFailure {
  const SidecarFailure({
    required this.id,
    required this.path,
    required this.error,
  });

  final String id;
  final String path;
  final String error;
}
