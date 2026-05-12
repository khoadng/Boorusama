import 'dart:io';

final class Artifact {
  const Artifact({required this.type, required this.files});

  Artifact.single({required this.type, required File file}) : files = [file];

  final String type;
  final List<File> files;

  File get file => files.single;
}
