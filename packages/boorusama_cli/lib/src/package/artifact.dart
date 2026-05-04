import 'dart:io';

final class Artifact {
  const Artifact({required this.type, required this.file});

  final String type;
  final File file;
}
