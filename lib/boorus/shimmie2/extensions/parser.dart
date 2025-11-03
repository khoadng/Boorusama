// Package imports:
import 'package:booru_clients/shimmie2.dart';

// Project imports:
import 'types.dart';

Extension extensionDtoToExtension(ExtensionDto dto) {
  return Extension(
    name: dto.name,
    description: dto.description,
    category: dto.category,
    docLink: dto.docLink,
  );
}
