// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:equatable/equatable.dart';

export 'package:booru_clients/shimmie2.dart' show ExtensionDto;
export 'known_extensions.dart';

class Extension extends Equatable {
  const Extension({
    required this.name,
    required this.description,
    required this.category,
    this.docLink,
  });

  factory Extension.fromDto(ExtensionDto dto) => Extension(
    name: dto.name,
    description: dto.description,
    category: dto.category,
    docLink: dto.docLink,
  );

  final String name;
  final String description;
  final String category;
  final String? docLink;

  @override
  List<Object?> get props => [
    name,
    description,
    category,
    docLink,
  ];
}
