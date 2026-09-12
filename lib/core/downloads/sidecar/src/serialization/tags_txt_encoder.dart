import '../types/sidecar_snapshot.dart';

String encodeTagsTxt(SidecarSnapshot snapshot) {
  if (snapshot.tags.any((tag) => tag.contains('\n') || tag.contains('\r'))) {
    throw const FormatException('Tags containing line breaks require JSON');
  }
  return snapshot.tags.isEmpty ? '' : '${snapshot.tags.join('\n')}\n';
}
