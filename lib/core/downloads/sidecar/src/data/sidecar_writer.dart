// Package imports:
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../../foundation/filesystem.dart';
import '../serialization/metadata_json_encoder.dart';
import '../serialization/tags_txt_encoder.dart';
import '../types/sidecar_format.dart';
import '../types/sidecar_snapshot.dart';

class SidecarWriter {
  const SidecarWriter({required this.fs});

  final AppFileSystem fs;

  String encode(SidecarSnapshot snapshot, String mediaPath) =>
      switch (snapshot.format) {
        SidecarFormat.off => throw StateError('Cannot write disabled sidecar'),
        SidecarFormat.tags => encodeTagsTxt(snapshot),
        SidecarFormat.json => encodeMetadataJson(
          snapshot,
          p.basename(mediaPath),
        ),
      };

  Future<void> checkDestination(
    String mediaPath,
    SidecarSnapshot snapshot,
  ) async {
    encode(snapshot, mediaPath); // Validate before downloading any media.
    final directory = p.dirname(mediaPath);
    await fs.createDirectory(directory, recursive: true);
    final probe = p.join(
      directory,
      '.${const Uuid().v4()}.sidecar-probe.${snapshot.format.extension}',
    );
    try {
      await fs.writeString(probe, '', flush: true);
    } finally {
      await fs.deleteFileIfExists(probe);
    }
  }

  Future<void> write(String mediaPath, SidecarSnapshot snapshot) async {
    if (!await fs.fileExists(mediaPath)) {
      throw StateError('Downloaded media is missing: $mediaPath');
    }
    final destination = '$mediaPath.${snapshot.format.extension}';
    final content = encode(snapshot, mediaPath);
    if (await fs.fileExists(destination)) {
      if (await fs.readString(destination) == content) return;
      throw StateError('Existing metadata file conflicts: $destination');
    }
    final temporary = '$destination.${const Uuid().v4()}.tmp';
    try {
      await fs.writeString(temporary, content, flush: true);
      // Do not knowingly replace a sidecar created while preparing the output.
      if (await fs.fileExists(destination)) {
        if (await fs.readString(destination) == content) return;
        throw StateError('Existing metadata file conflicts: $destination');
      }
      await fs.renameFile(temporary, destination);
    } finally {
      await fs.deleteFileIfExists(temporary);
    }
  }
}
