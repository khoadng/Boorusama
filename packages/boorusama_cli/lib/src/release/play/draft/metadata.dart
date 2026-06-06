import '../../../io/process_runner.dart';
import '../repository.dart';

final class PlayReleaseMetadata {
  const PlayReleaseMetadata({
    required this.name,
    required this.notes,
  });

  final String name;
  final PlayReleaseNote notes;

  String get consoleNotes {
    return '<${notes.language}>\n${notes.text}\n</${notes.language}>';
  }
}

final class PlayReleaseMetadataBuilder {
  const PlayReleaseMetadataBuilder();

  static const maxNameLength = 50;
  static const maxNotesLength = 500;

  PlayReleaseMetadata build({
    required String name,
    required String changelogSection,
    required String language,
  }) {
    final normalizedName = name.trim();
    final normalizedLanguage = language.trim();
    final notes = changelogSection.trim();

    if (normalizedName.isEmpty) {
      throw const ProcessFailure('Google Play release name is empty.');
    }
    if (normalizedName.length > maxNameLength) {
      throw ProcessFailure(
        'Google Play release name is ${normalizedName.length} characters. Maximum is $maxNameLength.',
      );
    }
    if (normalizedLanguage.isEmpty) {
      throw const ProcessFailure(
        'Google Play release notes language is empty.',
      );
    }
    if (notes.isEmpty) {
      throw const ProcessFailure('Google Play release notes are empty.');
    }
    if (notes.length > maxNotesLength) {
      throw ProcessFailure(
        'Google Play release notes are ${notes.length} characters. Maximum is $maxNotesLength.',
      );
    }

    return PlayReleaseMetadata(
      name: normalizedName,
      notes: PlayReleaseNote(language: normalizedLanguage, text: notes),
    );
  }
}
